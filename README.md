# EasePi-R2 Armbian Build

这是一个给 **EasePi-R2 / RK3588** 编译自定义 Armbian 镜像的构建套件。

当前仓库根目录应包含：

```text
EasePi-R2-Armbian-Build/
├── build.sh
├── README.md
├── LICENSE
├── .gitattributes
└── userpatches/
    ├── config/
    ├── kernel/
    ├── u-boot/
    ├── extensions/
    ├── overlay/
    └── customize-image.sh
```

支持三类镜像：

| 类型 | 命令参数 | 适合用途 |
|---|---|---|
| 最小镜像 | `minimal` | 首次验证启动、调试设备树、测试基础驱动 |
| 服务端镜像 | `server` | 路由器、NAS、Docker、LXC、OpenWrt LXC 底座 |
| 桌面镜像 | `desktop` | HDMI、XFCE、浏览器、远程桌面、GPU 图形测试 |

支持三条内核路线：

| 分支 | 命令参数 | 适合用途 |
|---|---|---|
| 主线常规分支 | `current` | 默认推荐，优先测试主线内核 |
| 主线测试分支 | `edge` | 测试更新内核、新驱动、新补丁 |
| Rockchip 厂商分支 | `vendor` | 测试 NPU、MPP、RGA、VPU 等厂商生态能力 |

---

## 一、准备编译环境

推荐使用：

```text
Ubuntu 24.04 / Ubuntu 22.04 / Debian 12 / Debian 13
```

建议配置：

```text
CPU：4 核以上
内存：8GB 起步，推荐 16GB 以上
磁盘：80GB 起步，推荐 150GB 以上
网络：能访问 GitHub、Debian / Ubuntu / Armbian 软件源
```

Windows 用户建议使用 **WSL2 Ubuntu 24.04**。

安装基础依赖：

```bash
sudo apt update
sudo apt install -y git curl wget rsync unzip xz-utils \
  build-essential gcc g++ make bc bison flex \
  libssl-dev libncurses-dev python3 python3-pip \
  python3-setuptools file cpio qemu-user-static \
  binfmt-support debootstrap ca-certificates
```

---

## 二、下载 Armbian build 和本仓库

建议统一放到 `~/rk3588_build`：

```bash
mkdir -p ~/rk3588_build
cd ~/rk3588_build

git clone --depth=1 https://github.com/armbian/build.git build
git clone https://github.com/fk1124/EasePi-R2-Armbian-Build.git
```

最终目录结构建议是：

```text
~/rk3588_build/
├── build/                         # Armbian 官方 build 源码
└── EasePi-R2-Armbian-Build/        # 本仓库
    ├── build.sh
    ├── README.md
    └── userpatches/
```

---

## 三、放入 EasePi-R2 配置

进入本仓库：

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
```

把 `userpatches/` 同步到 Armbian build 目录：

```bash
rsync -a userpatches/ ../build/userpatches/
chmod +x build.sh
```

确认板级配置已经放好：

```bash
ls ../build/userpatches/config/boards/easepi-r2.conf
```

能看到文件路径，说明配置正常。

---

## 四、编译三类镜像

命令格式：

```bash
bash build.sh [内核分支] [系统版本] [镜像类型]
```

常用参数：

```text
内核分支：current / edge / vendor
系统版本：trixie / bookworm
镜像类型：minimal / server / desktop
```

默认推荐使用：

```bash
bash build.sh current trixie minimal
```

---

## 五、编译 minimal 镜像

首次测试建议先编译 minimal，体积最小，最适合验证能不能启动。

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie minimal
```

含义：

```text
current  = 主线常规内核
trixie   = Debian 13
minimal  = 最小镜像
```

适合验证：

```text
启动链
设备树
TF / eMMC
基础网口
USB
基础 SSH 登录
```

---

## 六、编译 server 镜像

server 适合长期作为无桌面系统使用。

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie server
```

适合用途：

```text
主路由底座
Docker
LXC
OpenWrt LXC
NAS 服务
轻量服务器
```

---

## 七、编译 desktop 镜像

desktop 适合测试图形界面和 HDMI 输出。

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie desktop
```

适合用途：

```text
HDMI 显示
XFCE 桌面
浏览器
远程桌面
GPU 图形环境测试
```

建议先确认 `minimal` 可以正常启动，再编译 `desktop`。

---

## 八、测试不同内核分支

### 1. current：默认推荐

```bash
bash build.sh current trixie minimal
```

适合主线内核日常测试。

---

### 2. edge：更新主线测试版

```bash
bash build.sh edge trixie minimal
```

适合测试更新内核、新驱动、新设备树变化。

---

### 3. vendor：Rockchip 厂商内核

```bash
bash build.sh vendor trixie minimal
```

如果 `vendor + trixie` 编译失败，可以改用：

```bash
bash build.sh vendor bookworm minimal
```

vendor 分支更适合测试：

```text
RKNPU
MPP
RGA
VPU
Rockchip BSP 相关能力
```

---

## 九、编译产物位置

编译成功后，镜像一般在：

```bash
~/rk3588_build/build/output/images/
```

查看镜像：

```bash
ls -lh ~/rk3588_build/build/output/images/
```

常见产物类似：

```text
Armbian-unofficial_*.img
Armbian-unofficial_*.img.xz
Armbian-unofficial_*.sha
```

可以把 `.img` 或 `.img.xz` 写入 TF 卡、USB 存储或 eMMC 测试。

---

## 十、一键复制版

从零开始，直接执行：

```bash
sudo apt update
sudo apt install -y git curl wget rsync unzip xz-utils \
  build-essential gcc g++ make bc bison flex \
  libssl-dev libncurses-dev python3 python3-pip \
  python3-setuptools file cpio qemu-user-static \
  binfmt-support debootstrap ca-certificates

mkdir -p ~/rk3588_build
cd ~/rk3588_build

git clone --depth=1 https://github.com/armbian/build.git build
git clone https://github.com/fk1124/EasePi-R2-Armbian-Build.git

cd EasePi-R2-Armbian-Build
rsync -a userpatches/ ../build/userpatches/
chmod +x build.sh

bash build.sh current trixie minimal
```

编译成功后查看镜像：

```bash
ls -lh ~/rk3588_build/build/output/images/
```

---

## 十一、更新仓库后重新编译

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

重新同步 `userpatches/`：

```bash
rsync -a userpatches/ ../build/userpatches/
```

重新编译：

```bash
bash build.sh current trixie minimal
```

---

## 十二、常见问题

### 1. 提示找不到 Armbian build 目录

如果出现：

```text
ERROR: Cannot find Armbian build directory.
```

说明 `build.sh` 没找到官方 Armbian `build/` 目录。

推荐目录结构：

```text
~/rk3588_build/
├── build/
└── EasePi-R2-Armbian-Build/
```

如果你的目录不一样，可以手动指定：

```bash
export ARMBIAN_BUILD_DIR=/你的路径/build
bash build.sh current trixie minimal
```

---

### 2. 提示找不到 easepi-r2.conf

如果出现：

```text
ERROR: easepi-r2.conf not found
```

说明还没把本仓库的 `userpatches/` 同步到 Armbian build 目录。

执行：

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
rsync -a userpatches/ ../build/userpatches/
bash build.sh current trixie minimal
```

---

### 3. 上次编译失败后，重新编译仍然失败

可以先清理部分缓存：

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

---

### 4. 想临时关闭红外 / 蓝牙扩展

默认会启用 EasePi-R2 红外、蓝牙相关扩展。

如需临时关闭：

```bash
EASEPI_R2_PERIPHERALS=no bash build.sh current trixie minimal
```

---

## 十三、推荐编译顺序

建议按这个顺序测试：

```bash
# 1. 先验证最小主线镜像
bash build.sh current trixie minimal

# 2. 再验证服务端镜像
bash build.sh current trixie server

# 3. 最后验证桌面镜像
bash build.sh current trixie desktop

# 4. 需要测试更新主线时
bash build.sh edge trixie minimal

# 5. 需要测试厂商内核时
bash build.sh vendor bookworm minimal
```

---

## 十四、重要提醒

本项目属于 EasePi-R2 自定义 Armbian 构建套件，适合开发、测试和折腾使用。

建议先写入 TF 卡测试启动，确认网口、存储、USB、HDMI、无线、蓝牙等功能正常后，再考虑写入 eMMC 或长期使用。
�重新编译：

```bash
cd ~/rk3588_build/EasePi-R2-Armbian-Build
bash build.sh current trixie minimal
```

---

### 4. 想临时关闭红外 / 蓝牙扩展

默认会启用 EasePi-R2 红外、蓝牙相关扩展。

如需临时关闭：

```bash
EASEPI_R2_PERIPHERALS=no bash build.sh current trixie minimal
```

---

## 十三、推荐编译顺序

建议按这个顺序测试：

```bash
# 1. 先验证最小主线镜像
bash build.sh current trixie minimal

# 2. 再验证服务端镜像
bash build.sh current trixie server

# 3. 最后验证桌面镜像
bash build.sh current trixie desktop

# 4. 需要测试更新主线时
bash build.sh edge trixie minimal

# 5. 需要测试厂商内核时
bash build.sh vendor bookworm minimal
```

---

## 十四、重要提醒

本项目属于 EasePi-R2 自定义 Armbian 构建套件，适合开发、测试和折腾使用。

建议先写入 TF 卡测试启动，确认网口、存储、USB、HDMI、无线、蓝牙等功能正常�