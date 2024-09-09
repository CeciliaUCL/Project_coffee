from flask import Flask, request, jsonify, redirect
import requests
import json
import os
import subprocess
import psutil
from urllib.parse import unquote
import socket
import pyautogui
import pygetwindow as gw
from pywinauto import Application
import threading
import time
import traceback

app = Flask(__name__)

# 配置
client_id = '80840A20EDD4AC02F079C0B7493FB2BC6BCC7862D4BBB13D9688894A3438D983'
client_secret = '013BD6637022D45D4653F611C0F95B8B7D41CAC92E18C18A0B9AF8907A7116D6'
redirect_uri = 'https://webhook.site/8b0a17d4-8c96-4702-aacd-8bf34ab266ba'
authorization_base_url = 'https://simulator.home-connect.com/security/oauth/authorize'
token_url = 'https://simulator.home-connect.com/security/oauth/token'
appliance_id = 'BOSCH-HCS06COM1-D70390681C2C'
token_file = '../tokens.json'


# 工具函数
def save_tokens(tokens):
    with open(token_file, 'w') as f:
        json.dump(tokens, f)


def load_tokens():
    if os.path.exists(token_file):
        with open(token_file, 'r') as f:
            return json.load(f)
    return {}


def get_access_token():
    tokens = load_tokens()
    return tokens.get('access_token')


def refresh_access_token():
    tokens = load_tokens()
    refresh_token = tokens.get('refresh_token')
    response = requests.post(token_url, data={
        'grant_type': 'refresh_token',
        'refresh_token': refresh_token,
        'client_id': client_id,
        'client_secret': client_secret,
    })
    if response.status_code == 200:
        new_tokens = response.json()
        save_tokens(new_tokens)
        return new_tokens['access_token']
    return None


# OAuth2 流程
@app.route('/')
def index():
    authorization_url = (
        f'{authorization_base_url}?response_type=code&client_id={client_id}&redirect_uri={redirect_uri}'
        '&scope=IdentifyAppliance%20Monitor%20Control'
    )
    return redirect(authorization_url)


@app.route('/callback')
def callback():
    code = request.args.get('code')
    response = requests.post(
        token_url,
        data={'grant_type': 'authorization_code', 'code': code, 'redirect_uri': redirect_uri},
        auth=(client_id, client_secret)
    )
    if response.status_code == 200:
        tokens = response.json()
        save_tokens(tokens)
        return "Authorization successful, you can now close this window."
    else:
        return f"Error: {response.text}", response.status_code


@app.route('/token', methods=['POST'])
def get_token():
    code = request.form.get('code')
    response = requests.post(
        token_url,
        data={'grant_type': 'authorization_code', 'code': code, 'redirect_uri': redirect_uri},
        auth=(client_id, client_secret)
    )
    if response.status_code == 200:
        tokens = response.json()
        save_tokens(tokens)
        return jsonify(tokens)
    else:
        return jsonify({"error": response.text}), response.status_code


# 设备控制功能
@app.route('/start_coffee_machine', methods=['POST'])
def start_coffee_machine():
    access_token = get_access_token()
    if not access_token:
        return jsonify({"error": "Access token is missing. Please re-authenticate."}), 401

    data = request.json
    coffee_type = unquote(data.get('coffee_type'))
    fill_quantity = data.get('fill_quantity')
    strength = unquote(data.get('strength'))

    start_program_url = f'https://simulator.home-connect.com/api/homeappliances/{appliance_id}/programs/active'
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    payload = {
        "data": {
            "key": f"ConsumerProducts.CoffeeMaker.Program.Beverage.{coffee_type.replace(' ', '').replace('+', 'Plus')}",
            "options": [
                {
                    "key": "ConsumerProducts.CoffeeMaker.Option.BeanAmount",
                    "value": f"ConsumerProducts.CoffeeMaker.EnumType.BeanAmount.{strength.replace(' ', '').replace('+', 'Plus')}"
                },
                {
                    "key": "ConsumerProducts.CoffeeMaker.Option.FillQuantity",
                    "value": fill_quantity
                }
            ]
        }
    }
    response = requests.put(start_program_url, headers=headers, json=payload)

    if response.status_code == 204:
        return jsonify({"message": "Coffee machine started successfully."})
    elif response.status_code == 401:
        access_token = refresh_access_token()
        if access_token:
            headers['Authorization'] = f'Bearer {access_token}'
            response = requests.put(start_program_url, headers=headers, json=payload)
            if response.status_code == 204:
                return jsonify({"message": "Coffee machine started successfully."})
        return jsonify({"message": f"Failed to start coffee machine: {response.text}"}), response.status_code
    else:
        return jsonify({"message": f"Failed to start coffee machine: {response.text}"}), response.status_code


@app.route('/get_devices', methods=['GET'])
def get_devices():
    access_token = get_access_token()
    if not access_token:
        return jsonify({"error": "Access token is missing. Please re-authenticate."}), 401

    appliances_url = 'https://simulator.home-connect.com/api/homeappliances'
    headers = {'Authorization': f'Bearer {access_token}'}
    response = requests.get(appliances_url, headers=headers)

    if response.status_code == 200:
        appliances = response.json()
        return jsonify(appliances)
    elif response.status_code == 401:
        access_token = refresh_access_token()
        if access_token:
            headers['Authorization'] = f'Bearer {access_token}'
            response = requests.get(appliances_url, headers=headers)
            if response.status_code == 200:
                appliances = response.json()
                return jsonify(appliances)
        return jsonify({"message": f"Failed to fetch appliances: {response.text}"}), response.status_code
    else:
        return jsonify({"message": f"Failed to fetch appliances: {response.text}"}), response.status_code


@app.route('/logout', methods=['POST'])
def logout():
    if os.path.exists(token_file):
        os.remove(token_file)
    return jsonify({"message": "Logged out successfully."})


# 进程管理功能
process = None


@app.route('/stop', methods=['POST'])
def stop():
    global process
    if process is None:
        return jsonify({'error': 'No process running'}), 400
    try:
        parent = psutil.Process(process.pid)
        for child in parent.children(recursive=True):
            child.terminate()
        parent.terminate()
        process = None
        return jsonify({'message': 'Process terminated'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/run_circle', methods=['POST'])
def run_circle():
    print(f"Received request on Flask: {request.data}")
    global process
    if process is not None:
        # 尝试终止现有进程
        try:
            parent = psutil.Process(process.pid)
            for child in parent.children(recursive=True):  # 递归地终止子进程
                child.terminate()
            parent.terminate()
            process = None
        except psutil.NoSuchProcess:
            process = None
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    # 设置工作目录为exe所在的目录
    try:
        process = subprocess.Popen(
            [r'C:\Users\pc\Desktop\WirelessBoard_copy\WirelessBoard\runcircle.bat'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True,
            creationflags=subprocess.CREATE_NEW_CONSOLE,
            cwd=r'C:\Users\pc\Desktop\WirelessBoard_copy\WirelessBoard'  # 设置工作目录
        )
        return jsonify({'message': 'Process started'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# @app.route('/run_circle', methods=['POST'])
# def run_circle():
#     global process
#     if process is not None:
#         return jsonify({'error': 'Process already running'}), 400
#     process = subprocess.Popen(
#         [r'C:\Users\pc\Desktop\WirelessBoard_copy\WirelessBoard\runcircle.bat'],
#         stdout=subprocess.PIPE,
#         stderr=subprocess.PIPE,
#         shell=True,
#         creationflags=subprocess.CREATE_NEW_CONSOLE  # Ensures a new console window is created
#     )
#     return jsonify({'message': 'Process started'}), 200


@app.route('/run_square', methods=['POST'])
def run_square():
    global process
    if process is not None:
        return jsonify({'error': 'Process already running'}), 400
    process = subprocess.Popen(
        [r'C:\Users\pc\Desktop\WirelessBoard_copy\WirelessBoard\runsquare.bat'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True,
        creationflags=subprocess.CREATE_NEW_CONSOLE  # Ensures a new console window is created
    )
    return jsonify({'message': 'Process started'}), 200


@app.route('/run_triangle', methods=['POST'])
def run_triangle():
    global process
    if process is not None:
        return jsonify({'error': 'Process already running'}), 400
    process = subprocess.Popen(
        [r'C:\Users\pc\Desktop\WirelessBoard_copy\WirelessBoard\runtriangle.bat'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True,
        creationflags=subprocess.CREATE_NEW_CONSOLE  # Ensures a new console window is created
    )
    return jsonify({'message': 'Process started'}), 200


@app.route('/run_program', methods=['POST'])
def run_program():
    print(f"Received request on Flask: {request.data}")
    global process
    if process is not None:
        # Terminate existing process if any
        try:
            parent = psutil.Process(process.pid)
            for child in parent.children(recursive=True):  # Terminate child processes
                child.terminate()
            parent.terminate()
            process = None
        except psutil.NoSuchProcess:
            process = None
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    # Get the start time from the request
    try:
        start_time = request.json.get('start_time')
        if not start_time:
            raise ValueError("Missing start_time in request")

        # Record server-side start time
        server_start_time = int(time.time() * 1000)

        # Start the program
        process = subprocess.Popen(
            [r'C:\Users\pc\Desktop\WirelessBoard_final\WirelessBoard\x64\Debug\start.bat'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True,
            creationflags=subprocess.CREATE_NEW_CONSOLE,
            cwd=r'C:\Users\pc\Desktop\WirelessBoard_final\WirelessBoard\x64\Debug'  # Set working directory
        )

        # Calculate the time difference
        time_taken_by_backend = server_start_time - start_time
        print(f"Time taken to start the program: {time_taken_by_backend} ms")

        # Return the back-end time
        return jsonify({
            'message': 'Process started',
            'backend_time': time_taken_by_backend
        }), 200

    except Exception as e:
        print(f"Error starting program: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/stop_hardware_control', methods=['POST'])
def stop_hardware_control():
    global process
    if process is None:
        return jsonify({'error': 'No process running'}), 400

    process.terminate()
    process = None
    return jsonify({'message': 'Process terminated'}), 200


# 窗口和服务器管理
def focus_window(partial_title):
    try:
        windows = gw.getWindowsWithTitle(partial_title)
        if not windows:
            print(f"No window with title containing '{partial_title}' found.")
            return
        window = windows[0]  # 选择第一个匹配的窗口
        app = Application(backend='win32').connect(handle=window._hWnd)
        app[window.title].set_focus()
    except Exception as e:
        print(f"Failed to focus window: {e}")


def handle_client(client_socket, window_title):
    try:
        while True:
            data = client_socket.recv(1024).decode('utf-8')
            if not data:
                break
            print(f"Received data: {data}")  # Log received data
            focus_window(window_title)
            pyautogui.typewrite(data)
    finally:
        client_socket.close()


def start_server(window_title):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('0.0.0.0', 9999))
    server_socket.listen(5)
    print("Server started and waiting for connection...")

    while True:
        client_socket, addr = server_socket.accept()
        print(f"Connection from {addr} has been established.")
        client_handler = threading.Thread(target=handle_client, args=(client_socket, window_title))
        client_handler.start()


def run_flask():
    app.run(host='0.0.0.0', port=5000)


if __name__ == '__main__':
    target_window_title = "WirelessBoard.exe"
    flask_thread = threading.Thread(target=run_flask)
    flask_thread.start()
    server_thread = threading.Thread(target=start_server, args=(target_window_title,))
    server_thread.start()