import cv2
import numpy as np
import os
import glob

image_folder = r'C:\Users\pc\Desktop\Test2\shape2\triangle\calibration'
output_folder = os.path.join(image_folder, 'output')

points = []
image = None
original_image = None
current_image_path = ''
scale_factor = 1.0

def resize_image(img, scale=1.0):
    return cv2.resize(img, None, fx=scale, fy=scale)

def click_event(event, x, y, flags, param):
    global points, image
    if event == cv2.EVENT_LBUTTONDOWN:
        original_x, original_y = int(x / scale_factor), int(y / scale_factor)
        points.append((original_x, original_y))
        cv2.circle(image, (x, y), 3, (0, 255, 0), -1)
        update_image()

def update_image():
    global image
    image = resize_image(original_image, scale_factor)
    if len(points) > 0:
        pts = np.array([(int(p[0] * scale_factor), int(p[1] * scale_factor)) for p in points])
        cv2.polylines(image, [pts], isClosed=True, color=(255, 0, 0), thickness=2)
        for point in pts:
            cv2.circle(image, tuple(point), 3, (0, 255, 0), -1)
    cv2.imshow('Image', image)

def save_results(image, metrics, output_path, shape_name):
    result_image = original_image.copy()
    if len(points) > 0:
        pts = np.array(points)
        cv2.polylines(result_image, [pts], isClosed=True, color=(255, 0, 0), thickness=2)
        for point in pts:
            cv2.circle(result_image, tuple(point), 5, (0, 255, 0), -1)
    cv2.imwrite(os.path.join(output_path, 'shape_image.jpg'), result_image)

    with open(os.path.join(output_path, 'shape_metrics.txt'), 'w') as f:
        f.write(f"Shape Evaluation for {shape_name}:\n")
        for key, value in metrics.items():
            f.write(f"{key}: {value:.4f}\n")

def calculate_shape_metrics(points):
    perimeter = 0
    for i in range(len(points)):
        perimeter += np.sqrt(np.sum((np.array(points[i]) - np.array(points[i - 1])) ** 2))

    area = 0
    for i in range(len(points)):
        j = (i + 1) % len(points)
        area += points[i][0] * points[j][1]
        area -= points[j][0] * points[i][1]
    area = abs(area) / 2.0

    circularity = (4 * np.pi * area) / (perimeter ** 2) if perimeter > 0 else 0

    return perimeter, area, circularity


# def save_results(image, metrics, output_path):
#     # 保存带有形状的原始大小图像
#     result_image = original_image.copy()
#     for i, point in enumerate(points):
#         cv2.circle(result_image, point, 5, (0, 255, 0), -1)
#         if i > 0:
#             cv2.line(result_image, points[i - 1], point, (255, 0, 0), 2)
#     cv2.line(result_image, points[-1], points[0], (255, 0, 0), 2)
#     cv2.imwrite(os.path.join(output_path, 'shape_image.jpg'), result_image)
#
#     # 保存度量结果到文本文件
#     with open(os.path.join(output_path, 'shape_metrics.txt'), 'w') as f:
#         f.write(f"Shape Metrics:\n")
#         f.write(f"Perimeter: {metrics['perimeter']:.2f} pixels\n")
#         f.write(f"Area: {metrics['area']:.2f} square pixels\n")
#         f.write(f"Circularity: {metrics['circularity']:.4f}\n")


def undo_last_point():
    global points, image
    if points:
        points.pop()
        image = resize_image(original_image, scale_factor)
        for i, point in enumerate(points):
            x, y = int(point[0] * scale_factor), int(point[1] * scale_factor)
            cv2.circle(image, (x, y), 3, (0, 255, 0), -1)
            if i > 0:
                prev_x, prev_y = int(points[i - 1][0] * scale_factor), int(points[i - 1][1] * scale_factor)
                cv2.line(image, (prev_x, prev_y), (x, y), (255, 0, 0), 2)
        cv2.imshow('Image', image)





def calculate_edge_lengths(points):
    return [np.linalg.norm(np.array(points[i]) - np.array(points[i - 1])) for i in range(len(points))]


def calculate_angles(points):
    angles = []
    for i in range(len(points)):
        p1 = np.array(points[i - 1])
        p2 = np.array(points[i])
        p3 = np.array(points[(i + 1) % len(points)])
        v1 = p1 - p2
        v2 = p3 - p2
        angle = np.degrees(np.arccos(np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))))
        angles.append(angle)
    return angles



def evaluate_square(points):
    edges = calculate_edge_lengths(points)
    angles = calculate_angles(points)

    edge_similarity = 1 - (np.std(edges) / np.mean(edges))
    angle_similarity = 1 - (np.std(angles) / 90)

    return {
        "edge_similarity": edge_similarity,
        "angle_similarity": angle_similarity,
        "squareness": (edge_similarity + angle_similarity) / 2
    }


def evaluate_pentagon(points):
    edges = calculate_edge_lengths(points)
    angles = calculate_angles(points)

    edge_similarity = 1 - (np.std(edges) / np.mean(edges))
    angle_similarity = 1 - (np.mean(np.abs(np.array(angles) - 108)) / 108)

    return {
        "edge_similarity": edge_similarity,
        "angle_similarity": angle_similarity,
        "pentagonness": (edge_similarity + angle_similarity) / 2
    }


def evaluate_hexagon(points):
    edges = calculate_edge_lengths(points)
    angles = calculate_angles(points)

    edge_similarity = 1 - (np.std(edges) / np.mean(edges))
    angle_similarity = 1 - (np.mean(np.abs(np.array(angles) - 120)) / 120)

    return {
        "edge_similarity": edge_similarity,
        "angle_similarity": angle_similarity,
        "hexagonness": (edge_similarity + angle_similarity) / 2
    }

def evaluate_triangle(points):
    edges = calculate_edge_lengths(points)
    angles = calculate_angles(points)

    # 计算边长相似度
    edge_similarity = 1 - (np.std(edges) / np.mean(edges))  # 边长相似度

    # 计算角度相似度（三角形的理想角度是60度）
    angle_similarity = 1 - (np.mean(np.abs(np.array(angles) - 60)) / 60)  # 角度相似度

    return {
        "edge_similarity": edge_similarity,
        "angle_similarity": angle_similarity,
        "triangularity": (edge_similarity + angle_similarity) / 2  # 综合指标
    }


def evaluate_shape(points):
    if len(points) == 3:
        return "Triangle", evaluate_triangle(points)
    elif len(points) == 4:
        return "Square", evaluate_square(points)
    elif len(points) == 5:
        return "Pentagon", evaluate_pentagon(points)
    elif len(points) == 6:
        return "Hexagon", evaluate_hexagon(points)
    else:
        return "Unknown", {}


def calculate_centroid(points):
    """计算多边形的重心"""
    x = [p[0] for p in points]
    y = [p[1] for p in points]
    centroid_x = sum(x) / len(points)
    centroid_y = sum(y) / len(points)
    return (centroid_x, centroid_y)


def calculate_displacement(centroid, image_center):
    """计算重心相对于图像中心的偏移"""
    return np.sqrt((centroid[0] - image_center[0]) ** 2 + (centroid[1] - image_center[1]) ** 2)


def analyze_shape_distribution(all_shapes):
    """分析形状分布的集中性与偏移性"""
    centroids = [calculate_centroid(shape['points']) for shape in all_shapes]
    image_center = (original_image.shape[1] / 2, original_image.shape[0] / 2)
    displacements = [calculate_displacement(centroid, image_center) for centroid in centroids]

    avg_displacement = np.mean(displacements)
    std_displacement = np.std(displacements)

    return {
        "average_displacement": avg_displacement,
        "displacement_std": std_displacement,
        "centrality": 1 - (avg_displacement / (min(image_center) / 2)),  # 归一化的集中度
        "consistency": 1 - (std_displacement / avg_displacement) if avg_displacement > 0 else 0  # 一致性
    }


def compare_shapes(shape1, shape2):
    """比较两个形状的相似度"""
    if len(shape1) != len(shape2):
        return 0  # 如果点的数量不同，认为完全不相似

    # 计算边长和角度
    edges1 = calculate_edge_lengths(shape1)
    edges2 = calculate_edge_lengths(shape2)
    angles1 = calculate_angles(shape1)
    angles2 = calculate_angles(shape2)

    # 计算边长和角度的相似度
    edge_similarity = 1 - np.mean(np.abs(np.array(edges1) - np.array(edges2)) / np.mean(edges1))
    angle_similarity = 1 - np.mean(np.abs(np.array(angles1) - np.array(angles2)) / 180)

    return (edge_similarity + angle_similarity) / 2


def analyze_shape_consistency(all_shapes):
    """分析形状一致性与生成重复性"""
    if len(all_shapes) < 2:
        return {"consistency": 0, "repeatability": 0}

    similarities = []
    for i in range(len(all_shapes)):
        for j in range(i + 1, len(all_shapes)):
            similarity = compare_shapes(all_shapes[i]['points'], all_shapes[j]['points'])
            similarities.append(similarity)

    avg_similarity = np.mean(similarities)
    std_similarity = np.std(similarities)

    return {
        "consistency": avg_similarity,
        "repeatability": 1 - std_similarity
    }


def process_image(image_path):

    global image, original_image, points, current_image_path, scale_factor
    current_image_path = image_path
    original_image = cv2.imread(image_path)
    if original_image is None:
        print(f"Error: Unable to load image {image_path}")
        return

    # 计算初始缩放因子，使最长边不超过400像素
    max_dimension = max(original_image.shape[:2])
    scale_factor = min(400 / max_dimension, 1.0)

    image = resize_image(original_image, scale_factor)
    points = []
    cv2.imshow('Image', image)
    cv2.setMouseCallback('Image', click_event)

    print(f"\nProcessing image: {os.path.basename(image_path)}")
    print("Click on the image to select points.")
    print("Press 'u' to undo the last point.")
    print("Press '+' to zoom in, '-' to zoom out.")
    print("Press '1' to zoom to 10%, '2' to 25%, '3' to 50%, '4' to 100%.")
    print("Press 'q' to finish and evaluate the shape.")
    print("Press 's' to skip this image.")

    while True:
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('u'):
            undo_last_point()
        elif key == ord('s'):
            print("Skipping this image.")
            return
        elif key == ord('+') or key == ord('='):
            scale_factor *= 1.25
            update_image()
        elif key == ord('-') or key == ord('_'):
            scale_factor *= 0.8
            update_image()
        elif key == ord('1'):
            scale_factor = 0.1
            update_image()
        elif key == ord('2'):
            scale_factor = 0.25
            update_image()
        elif key == ord('3'):
            scale_factor = 0.5
            update_image()
        elif key == ord('4'):
            scale_factor = 1.0
            update_image()

    if len(points) < 3:
        print("Not enough points to form a shape. Skipping this image.")
        return None

    shape_name, metrics = evaluate_shape(points)

    print(f"\nShape Evaluation for {shape_name}:")
    for key, value in metrics.items():
        print(f"{key}: {value:.4f}")

    # 保存结果
    image_name = os.path.splitext(os.path.basename(image_path))[0]
    image_output_folder = os.path.join(output_folder, image_name)
    if not os.path.exists(image_output_folder):
        os.makedirs(image_output_folder)

    save_results(image, metrics, image_output_folder, shape_name)

    return {"name": shape_name, "metrics": metrics, "points": points}

def save_results(image, metrics, output_path, shape_name):
    # 保存带有形状的原始大小图像
    result_image = original_image.copy()
    for i, point in enumerate(points):
        cv2.circle(result_image, point, 5, (0, 255, 0), -1)
        if i > 0:
            cv2.line(result_image, points[i - 1], point, (255, 0, 0), 2)
    if len(points) > 2:
        cv2.line(result_image, points[-1], points[0], (255, 0, 0), 2)
    cv2.imwrite(os.path.join(output_path, 'shape_image.jpg'), result_image)

    # 保存度量结果到文本文件
    with open(os.path.join(output_path, 'shape_metrics.txt'), 'w') as f:
        f.write(f"Shape Evaluation for {shape_name}:\n")
        for key, value in metrics.items():
            f.write(f"{key}: {value:.4f}\n")


def main():
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    image_files = glob.glob(os.path.join(image_folder, '*.jpg')) + glob.glob(os.path.join(image_folder, '*.png'))

    if not image_files:
        print(f"No image files found in {image_folder}")
        return

    all_shapes = []
    for image_path in image_files:
        shape_data = process_image(image_path)
        if shape_data:
            all_shapes.append(shape_data)

    cv2.destroyAllWindows()

    if all_shapes:
        distribution_analysis = analyze_shape_distribution(all_shapes)
        consistency_analysis = analyze_shape_consistency(all_shapes)

        print("\nShape Distribution Analysis:")
        for key, value in distribution_analysis.items():
            print(f"{key}: {value:.4f}")

        print("\nShape Consistency Analysis:")
        for key, value in consistency_analysis.items():
            print(f"{key}: {value:.4f}")

        # 保存总体分析结果
        with open(os.path.join(output_folder, 'overall_analysis.txt'), 'w') as f:
            f.write("Shape Distribution Analysis:\n")
            for key, value in distribution_analysis.items():
                f.write(f"{key}: {value:.4f}\n")
            f.write("\nShape Consistency Analysis:\n")
            for key, value in consistency_analysis.items():
                f.write(f"{key}: {value:.4f}\n")

    print("All images processed.")

if __name__ == "__main__":
    main()

