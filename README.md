# EasePi-R2 Armbian Build

给 **EasePi-R2 / RK3588** 编译 Armbian 镜像。

本仓库提供 EasePi-R2 的 Armbian `userpatches` 配置和一键编译脚本，支持编译：

```text
minimal   最小系统镜像
server    服务端镜像
desktop   桌面版镜像
```

---

## 一、基础环境要求

推荐使用 **原生 Linux 主机** 或 **Linux 虚拟机**。

推荐系统：

```text
Ubuntu 24.04
Ubuntu 22.04
Debian 12
Debian 13
```

不推荐使用 WSL 编译，可能遇到文件系统、权限、loop 设备、binfmt、Docker、网络缓存等问题。

建议配置：

```text
CPU：4 核以上
内存：8GB 起步，推荐 16GB 以上
磁盘：80GB 起步，推荐 150GB 以上
网络：能正常访问 GitHub 和 Debian / Ubuntu 软件源
```

建议目录结构：

```text
~/rk3588_build/
├── build/                         # Armbian 官方 build 源码
└── EasePi-R2-Armbian-Build/        # 本仓库
    ├── build.sh
    ├── README.md
    └── userpatches/
```

---

## 二、安装依赖

```bash
sudo apt update
sudo apt install -y git curl wget rsync unzip xz-utils
sudo apt install -y build-essential gcc g++ make bc bison flex
sudo apt install -y libssl-dev libncurses-dev python3 python3-pip python3-setuptools
sudo apt install -y file cpio qemu-user-static binfmt-support debootstrap ca-certificates
```

---

## 三、下载源码

```bash
mkdir -p ~/rk3588_build
cd ~/rk3588_build

git clone --depth=1 https://github.com/armbian/build.git build
git clone https://github.com/fk1124/EasePi-R2-Armbian-Build.git
```

进入本仓库：

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
```

同步 EasePi-R2 配置：

```bash
rsync -a userpatches/ ../build/userpatches/
chmod +x build.sh
```

确认配置存在：

```bash
ls ../build/userpatches/config/boards/easepi-r2.conf
```

---

## 四、编译 minimal 镜像

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie minimal
```

`minimal` 是最小系统镜像，适合精简系统、命令行环境、基础服务场景。

---

## 五、编译 server 镜像

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie server
```

`server` 是服务端镜像，适合路由器底座、NAS、Docker、LXC、OpenWrt LXC、轻量服务器等场景。

---

## 六、编译 desktop 镜像

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie desktop
```

`desktop` 是桌面版镜像，适合 HDMI、本地图形界面、XFCE、浏览器、远程桌面等场景。

---

## 七、常用命令汇总

### current 主线常规内核

```bash
bash build.sh current trixie minimal
bash build.sh current trixie server
bash build.sh current trixie desktop
```

### edge 主线较新内核

```bash
bash build.sh edge trixie minimal
bash build.sh edge trixie server
bash build.sh edge trixie desktop
```

### vendor Rockchip 厂商内核

```bash
bash build.sh vendor trixie minimal
bash build.sh vendor trixie server
bash build.sh vendor trixie desktop
```

如果 `vendor + trixie` 编译不顺，可以使用 Debian 12：

```bash
bash build.sh vendor bookworm minimal
bash build.sh vendor bookworm server
bash build.sh vendor bookworm desktop
```

---

## 八、参数说明

命令格式：

```bash
bash build.sh [内核分支] [系统版本] [镜像类型]
```

内核分支：

```text
current   主线常规内核
edge      主线较新内核
vendor    Rockchip 厂商内核
```

系统版本：

```text
trixie     Debian 13
bookworm   Debian 12
```

镜像类型：

```text
minimal    最小系统镜像
server     服务端镜像
desktop    桌面版镜像
```

---

## 九、编译产物位置

编译完成后，镜像一般在：

```bash
~/rk3588_build/build/output/images/
```

查看镜像：

```bash
ls -lh ~/rk3588_build/build/output/images/
```

常见产物：

```text
Armbian-unofficial_*.img
Armbian-unofficial_*.img.xz
Armbian-unofficial_*.sha
```

可以将 `.img` 或 `.img.xz` 写入 TF 卡、USB 存储或 eMMC。

---

## 十、更新后重新编译

更新 Armbian build：

```bash
cd ~/rk3588_build/build
git pull --ff-only
```

更新本仓库：

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
git pull --ff-only
```

重新同步配置：

```bash
rsync -a userpatches/ ../build/userpatches/
```

重新编译：

```bash
bash build.sh current trixie minimal
```

---

## 十一、常见问题

### 1. 找不到 Armbian build 目录

如果提示：

```text
ERROR: Cannot find Armbian build directory.
```

请确认目录结构为：

```text
~/rk3588_build/
├── build/
└── EasePi-R2-Armbian-Build/
```

如果 Armbian build 在其他目录，可以手动指定：

```bash
export ARMBIAN_BUILD_DIR=/你的路径/build
bash build.sh current trixie minimal
```

### 2. 找不到 easepi-r2.conf

如果提示：

```text
ERROR: easepi-r2.conf not found
```

重新同步 `userpatches`：

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
rsync -a userpatches/ ../build/userpatches/
```

### 3. 需要清理缓存后重新编译

```bash
cd ~/rk3588_build/build

sudo rm -rf cache/sources/u-boot-worktree
sudo rm -rf cache/git-bare/u-boot
sudo rm -rf cache/memoize/git2info/*
```

然后重新编译：

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie minimal
```

### 4. 临时关闭外设扩展

默认启用 EasePi-R2 红外、蓝牙等外设扩展。

临时关闭：

```bash
EASEPI_R2_PERIPHERALS=no bash build.sh current trixie minimal
```

---

## 十二、仓库文件说明

```text
build.sh
```

编译入口脚本。

```text
userpatches/config/boards/easepi-r2.conf
```

EasePi-R2 板级配置文件。

```text
userpatches/kernel/
```

内核补丁目录。

```text
userpatches/u-boot/
```

U-Boot 补丁目录。

```text
userpatches/extensions/
```

Armbian 扩展脚本目录。

```text
userpatches/overlay/
```

写入最终系统镜像的覆盖文件目录。

```text
userpatches/customize-image.sh
```

镜像定制脚本。
ches/ ../build/userpatches/
```

### 3. 需要清理缓存后重新编译

```bash
cd ~/rk3588_build/build

sudo rm -rf cache/sour