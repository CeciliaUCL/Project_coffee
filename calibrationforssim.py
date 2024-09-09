import cv2
import numpy as np
import os

# 定义路径
input_dir = r'C:\Users\pc\Desktop\Test2\ssim\pentagon'
output_dir = r'C:\Users\pc\Desktop\Test2\ssim\pentagon\calibration'

# 确保输出目录存在
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 读取文件列表
image_files = [f for f in os.listdir(input_dir) if f.endswith('.jpg')]

# 选择第一张图像作为基准
base_image_path = os.path.join(input_dir, image_files[0])
base_image = cv2.imread(base_image_path)
base_gray = cv2.cvtColor(base_image, cv2.COLOR_BGR2GRAY)

# 初始化ORB特征检测器
orb = cv2.ORB_create()

# 检测基准图像的特征点和描述符
keypoints_base, descriptors_base = orb.detectAndCompute(base_gray, None)

# 定义裁剪区域的大小
crop_width = 1200  # 自定义宽度
crop_height = 1200 # 自定义高度

# 手动设置裁剪区域的起始位置（可以通过手动调试来确定这些值）
# 例如你可能通过调试确定了 (crop_x, crop_y) 为 (150, 100)
crop_x = 800  # 手动调试的X坐标起始位置
crop_y = 800  # 手动调试的Y坐标起始位置

# 处理每一张图像
for image_file in image_files:
    image_path = os.path.join(input_dir, image_file)
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # 检测当前图像的特征点和描述符
    keypoints, descriptors = orb.detectAndCompute(gray, None)

    # 使用BFMatcher进行特征点匹配
    bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
    matches = bf.match(descriptors_base, descriptors)
    matches = sorted(matches, key=lambda x: x.distance)

    # 提取匹配的关键点坐标
    src_pts = np.float32([keypoints_base[m.queryIdx].pt for m in matches]).reshape(-1, 1, 2)
    dst_pts = np.float32([keypoints[m.trainIdx].pt for m in matches]).reshape(-1, 1, 2)

    # 计算变换矩阵
    M, mask = cv2.findHomography(dst_pts, src_pts, cv2.RANSAC, 5.0)

    # 使用变换矩阵对当前图像进行对齐
    h, w = base_gray.shape
    aligned_image = cv2.warpPerspective(image, M, (w, h))

    # 裁剪对齐后的图像的指定区域
    cropped_image = aligned_image[crop_y:crop_y+crop_height, crop_x:crop_x+crop_width]

    # 保存裁剪后的图像
    output_image_path = os.path.join(output_dir, f'aligned_cropped_{image_file}')
    cv2.imwrite(output_image_path, cropped_image)

    print(f'Processed and saved: {output_image_path}')

print("All images have been processed and saved.")
