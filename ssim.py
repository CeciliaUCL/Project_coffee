import cv2
import numpy as np
import glob
import os
import matplotlib.pyplot as plt
import seaborn as sns

# 图像文件夹路径
image_folder = 'C:/Users/pc/Desktop/Test2/ssim/pentagon/calibration/'  # 请替换为你的图像路径
output_folder = 'C:/Users/pc/Desktop/Test2/ssim/pentagon/output/'  # 保存处理后的图像

# 如果输出文件夹不存在，则创建
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

# 加载文件夹中所有JPG图像
image_files = glob.glob(image_folder + '*.jpg')

# 确保有足够的图像进行比较
if len(image_files) < 2:
    print("Not enough images to compare. Please ensure there are at least 2 images in the folder.")
    exit()


# 从图像中心裁剪出一定比例的区域
def crop_center_proportion(image, crop_proportion=0.95):  # 默认裁剪80%的图像
    """
    从图像中心裁剪出一定比例的区域
    """
    h, w = image.shape[:2]  # 获取图像的高和宽
    new_h, new_w = int(h * crop_proportion), int(w * crop_proportion)  # 按比例缩放

    # 计算中心裁剪区域的起点
    top = (h - new_h) // 2
    left = (w - new_w) // 2

    # 裁剪中心区域
    cropped_image = image[top:top + new_h, left:left + new_w]
    return cropped_image


# 将图像转换为灰度、按比例裁剪中心区域并存储
images = []
for idx, file in enumerate(image_files):
    gray_image = cv2.imread(file, cv2.IMREAD_GRAYSCALE)

    # 按比例裁剪图像，默认裁剪90%的区域
    cropped_image = crop_center_proportion(gray_image, crop_proportion=0.95)  # 可以调整比例

    images.append(cropped_image)

    # 保存处理后的图像
    output_path = os.path.join(output_folder, f'processed_image_{idx + 1}.jpg')
    cv2.imwrite(output_path, cropped_image)


# 计算结构相似性函数
def compute_structure_similarity(img1, img2):
    # 计算图像的标准差
    sigma_x = np.std(img1)
    sigma_y = np.std(img2)

    # 计算图像的协方差
    sigma_xy = np.mean((img1 - np.mean(img1)) * (img2 - np.mean(img2)))

    # 避免除以零的情况
    if sigma_x == 0 or sigma_y == 0:
        return 0

    # 结构相似性
    structure_similarity = sigma_xy / (sigma_x * sigma_y)
    return structure_similarity


# 计算结构相似性矩阵
structure_sim_values = []
structure_sim_matrix = np.zeros((len(images), len(images)))

for i in range(len(images)):
    for j in range(i + 1, len(images)):
        struct_sim_value = compute_structure_similarity(images[i], images[j])
        structure_sim_values.append(struct_sim_value)
        structure_sim_matrix[i, j] = struct_sim_value
        structure_sim_matrix[j, i] = struct_sim_value
        print(f"Structure similarity between image {i + 1} and image {j + 1}: {struct_sim_value:.4f}")

# 计算平均值和标准偏差
mean_structure_sim = np.mean(structure_sim_values)
std_structure_sim = np.std(structure_sim_values)

# 输出结果
print("\nSummary of Structure Similarity Comparisons:")
print(f"Mean Structure Similarity: {mean_structure_sim:.4f}")
print(f"Standard Deviation of Structure Similarity: {std_structure_sim:.4f}")

# 在显示时临时将对角线设为1（但不修改原矩阵）
structure_sim_matrix_display = structure_sim_matrix.copy()
np.fill_diagonal(structure_sim_matrix_display, 1.0)

# 创建一个自定义的色彩映射，从浅黄到深红
colors = sns.color_palette("YlOrRd", as_cmap=True)

# 绘制热力图
plt.figure(figsize=(10, 8))
sns.heatmap(structure_sim_matrix_display, annot=True, fmt=".4f", cmap=colors, square=True)
plt.title('Structure Similarity Matrix')
plt.xlabel('Image Index')
plt.ylabel('Image Index')
plt.savefig(os.path.join(output_folder, 'structure_sim_matrix_heatmap.jpg'))
plt.show()
