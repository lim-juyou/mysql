# MySQL 命令行参数
# -P或--port：端口号
# -h或--hostname: 主机名或IP地址 本机的主机名：localhost 本机的IP地址：127.0.0.1
# -u或--username: 登录MySQL服务器的用户名
# -p或--password：登录MySQL服务器的密码
# -P、-h、-u这三个参数值前可加空格也可以省略空格
# -p参数值前不能加空格
# 例如：mysql -P 3306 -h localhost -u root -proot

# 如果使用默认3306端口号进行连接，可以省略-P
# 如果连接本机，可以省略-h
# 例如：mysql -u root -proot

# 建议不使用明文密码进行登录
# 例如：mysql -uroot -p

# 使用mysql命令行连接服务器时，可以同时打开一个数据库
# 例如：mysql -uroot -p 数据库名

# 使用完整的参数连接MySQL服务器
# mysql --port=3306 --hostname=localhost --username=root --password=root 数据库名






