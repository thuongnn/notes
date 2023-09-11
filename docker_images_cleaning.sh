#!/bin/bash

# Ngày hiện tại
current_date=$(date +%s)

# Số ngày để xem xét image đã không sử dụng
days_threshold=3

# Lặp qua danh sách tất cả các Docker images
for image_id in $(docker images -q); do
    # Lấy thông tin về image và lấy thời gian tạo
    image_info=$(docker image inspect -f '{{.Id}} {{.Created}}' $image_id)
    image_created=$(echo $image_info | awk '{print $2}')

    # Chuyển đổi thời gian tạo thành định dạng ngày
    created_date=$(date -d "$image_created" +%s)

    # Tính toán số ngày image đã tồn tại
    days_diff=$(( (current_date - created_date) / 86400 ))

    # Kiểm tra xem image đã tồn tại hơn 3 ngày chưa
    if [ $days_diff -ge $days_threshold ]; then
        # Xóa image nếu nó đã tồn tại hơn 3 ngày
        echo "Xóa image $image_id, được tạo vào $(date -d "$image_created" '+%Y-%m-%d %H:%M:%S')"
        docker rmi -f $image_id
    fi
done
