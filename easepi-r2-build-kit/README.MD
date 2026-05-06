# EasePi-R2 Armbian 可复现构建套件

本套件用于为 **EasePi-R2 / RK3588** 编译 Armbian 镜像，目标是提供一个干净、可复现、可维护的构建入口，支持根据需要选择 `current`、`edge`、`vendor` 等内核分支。

适用方向包括：

- EasePi-R2 主线 Armbian 镜像编译
- Debian / Armbian minimal 底座构建
- LXC / Docker / OpenWrt LXC 实验环境
- RK3588 主线内核设备树适配验证
- U-Boot 启动链和设备树调试
- 红外、蓝牙等基础外设支持

---

## 一、套件目录结构

```text
easepi-r2-build-kit/
├── build.sh
├── README.MD
└── userpatches/
    ├── config/
    │   └── boards/
    │       └── easepi-r2.conf
    │
    ├── linux-rockchip64-current.config
    ├── linux-rockchip64-edge.config
    ├── linux-rk35xx-vendor.config
    │
    ├── customize-image.sh
    │
    ├── extensions/
    │   └── easepi-r2-peripherals.sh
    │
    ├── overlay/
    │   └── easepi-r2-peripherals/
    │       ├── usr/local/sbin/bluetooth-hciattach.sh
    │       ├── etc/systemd/system/bluetooth-hciattach.service
    │       ├── etc/systemd/system/ir-keymap.service
    │       └── etc/rc_keymaps/easepi_remote
    │
    ├── kernel/archive/rockchip64-6.18/
    │   ├── 0000.patching_config.yaml
    │   └── dt/
    │       ├── rk3588-easepi-r2.dts
    │       ├── rk3588-rk806-single.dtsi
    │       ├── rk3588s-crypto.dtsi
    │       ├── rk3588s-gpu.dtsi
    │       ├── rk3588s-ip.dtsi
    │       ├── rk3588s-ip-supply.dtsi
    │       ├── rk3588s-npu.dtsi
    │       └── rk3588s-vpu.dtsi
    │
    └── u-boot/v2025.10/
        ├── 0000.patching_config.yaml
        ├── defconfig/easepi-r2-rk3588_defconfig
        ├── dt_uboot/rk3588-easepi-r2-u-boot.dtsi
        └── dt_upstream_rockchip/rk3588-easepi-r2.dts
```

---

## 二、支持的内核分支

本套件主要支持以下 Armbian 内核分支：

| 分支 | 说明 | 建议用途 |
|---|---|---|
| `current` | 当前主线稳定分支 | 推荐默认使用 |
| `edge` | 更新的主线测试分支 | 用于测试新内核、新驱动 |
| `vendor` | Rockchip / BSP 厂商分支 | 用于测试 RK 官方生态、NPU、MPP、RGA 等 |

默认推荐先编译：

```bash
bash build.sh current trixie minimal
```

如果需要测试厂商内核：

```bash
bash build.sh vendor trixie minimal
```

如果要测试更新内核：

```bash
bash build.sh edge trixie minimal
```

---

## 三、准备构建环境

建议使用 x86_64 Ubuntu / Debian 主机进行编译。

推荐环境：

- Ubuntu 22.04 / 24.04
- Debian 12 / 13
- CPU：4 核以上
- 内存：8GB 以上，推荐 16GB 以上
- 磁盘：至少 80GB 可用空间，推荐 150GB 以上
- 网络：可以访问 GitHub、Debian / Armbian 软件源

安装基础依赖：

```bash
sudo apt update
sudo apt install -y git curl wget unzip xz-utils build-essential \
    gcc g++ make bc bison flex libssl-dev libncurses-dev \
    python3 python3-pip python3-setuptools rsync file cpio \
    qemu-user-static binfmt-support debootstrap
```

---

## 四、获取 Armbian build 源码

进入一个合适的工作目录：

```bash
mkdir -p ~/armbian-build
cd ~/armbian-build
```

克隆 Armbian build：

```bash
git clone --depth=1 https://github.com/armbian/build.git
cd build
```

---

## 五、放入本套件

将本套件中的 `userpatches/` 和 `build.sh` 放到 Armbian build 根目录下。

最终结构应该类似：

```text
build/
├── compile.sh
├── build.sh
└── userpatches/
    ├── config/
    ├── kernel/
    ├── u-boot/
    ├── extensions/
    ├── overlay/
    └── ...
```

赋予构建脚本执行权限：

```bash
chmod +x build.sh
```

---

## 六、开始编译

### 1. 编译 current 主线 minimal 镜像

```bash
bash build.sh current trixie minimal
```

这是最推荐的默认编译方式。

含义：

- 板子：EasePi-R2
- 内核：current
- 发行版：Debian 13 Trixie
- 镜像类型：minimal

### 2. 编译 edge 分支镜像

```bash
bash build.sh edge trixie minimal
```

适合测试更新的主线内核和驱动。

### 3. 编译 vendor 分支镜像

```bash
bash build.sh vendor trixie minimal
```

适合测试 Rockchip BSP / vendor 内核相关能力。

如果 `trixie` 下 vendor 分支构建失败，可以尝试：

```bash
bash build.sh vendor bookworm minimal
```

### 4. 编译 server 镜像

```bash
bash build.sh current trixie server
```

`server` 相比 `minimal` 会包含更多常用组件。

### 5. 编译 desktop 镜像

```bash
bash build.sh current trixie desktop
```

桌面镜像体积更大，编译更慢。建议先确认 minimal 镜像可以正常启动，再考虑桌面版本。

---

## 七、build.sh 参数说明

基本格式：

```bash
bash build.sh [内核分支] [系统版本] [镜像类型]
```

示例：

```bash
bash build.sh current trixie minimal
bash build.sh edge trixie minimal
bash build.sh vendor bookworm minimal
```

参数说明：

| 参数 | 可选值 | 默认值 |
|---|---|---|
| 内核分支 | `current` / `edge` / `vendor` | `current` |
| 系统版本 | `trixie` / `bookworm` 等 | `trixie` |
| 镜像类型 | `minimal` / `server` / `desktop` | `minimal` |

也可以通过环境变量指定：

```bash
BRANCH=current RELEASE=trixie IMAGE_TYPE=minimal bash build.sh
```

---

## 八、主要文件说明

### 1. `userpatches/config/boards/easepi-r2.conf`

这是 EasePi-R2 的板级配置文件。

主要作用：

- 定义板子名称
- 指定 RK3588 family
- 指定启动设备树
- 指定 U-Boot defconfig
- 指定支持的内核分支
- 指定 current / edge 使用主线 U-Boot v2025.10
- 启用 EasePi-R2 外设扩展

其中关键项包括：

```bash
BOARD_NAME="EasePi-R2"
BOARDFAMILY="rockchip-rk3588"
BOOTCONFIG="easepi-r2-rk3588_defconfig"
BOOT_FDT_FILE="rockchip/rk3588-easepi-r2.dtb"
KERNEL_TARGET="current,edge,vendor"
```

### 2. `userpatches/kernel/archive/rockchip64-6.18/`

这是主线 6.18 内核相关的设备树补丁目录。

其中：

```text
0000.patching_config.yaml
```

用于告诉 Armbian 构建系统把 `dt/` 目录中的设备树文件复制到 Linux 内核源码树的 Rockchip DTS 目录，并让它们参与编译。

### 3. `rk3588-easepi-r2.dts`

这是 EasePi-R2 的 Linux 主设备树文件。

它描述了 EasePi-R2 的主要硬件：

- RK3588 SoC
- RK806 PMIC 电源管理
- 四个 PCIe 2.5G 网口
- TF 卡
- eMMC
- NVMe
- SATA
- USB
- AP6255 WiFi / Bluetooth
- HDMI 显示与音频
- 红外接收
- GPIO 风扇
- GPU
- NPU
- VPU / MPP / RGA
- Crypto / RNG

这是内核识别 EasePi-R2 硬件的核心文件。

### 4. `rk3588-rk806-single.dtsi`

这是 RK806 PMIC 电源管理配置。

它定义了 CPU、GPU、NPU、DDR、SD、eMMC、PCIe、HDMI 等硬件所需的电源 regulator。

如果这个文件配置错误，可能导致：

- 无法启动
- eMMC / TF 卡异常
- PCIe 网卡不稳定
- GPU / NPU 无法工作
- 重启或关机异常

### 5. `rk3588s-gpu.dtsi`

用于补充 RK3588 GPU 设备树节点和 OPP 频率表。

主要用于主线内核下的 Mali-G610 / Panthor 方向测试。

注意：设备树启用 GPU 并不等于桌面图形加速一定可用，还需要内核驱动、Mesa、用户态环境配合。

### 6. `rk3588s-npu.dtsi`

用于补充 RK3588 NPU 设备树节点。

主要用于 RKNPU 相关测试。

注意：NPU 是否真正可用，还取决于：

- 内核是否包含合适的 RKNPU 驱动
- 用户态是否安装 RKNN runtime
- 模型格式和运行环境是否匹配

### 7. `rk3588s-vpu.dtsi`

用于补充 RK3588 VPU、MPP、RGA、JPEG 编解码等多媒体相关节点。

适合后续测试：

- 视频硬解
- 视频硬编
- RGA 图像处理
- Jellyfin / FFmpeg 硬件转码
- Android / Redroid 图形视频能力

### 8. `rk3588s-crypto.dtsi`

用于启用 RK3588 硬件加密和随机数节点。

### 9. `userpatches/u-boot/v2025.10/`

这是主线 U-Boot v2025.10 的 EasePi-R2 适配目录。

主要包含：

```text
defconfig/easepi-r2-rk3588_defconfig
dt_upstream_rockchip/rk3588-easepi-r2.dts
dt_uboot/rk3588-easepi-r2-u-boot.dtsi
```

其中 `rk3588-easepi-r2-u-boot.dtsi` 中设置了 U-Boot 层面的启动顺序，目标是优先尝试 USB，然后 TF/SD，再 eMMC。

---

## 九、内核配置文件说明

本套件包含三个内核配置文件：

```text
userpatches/linux-rockchip64-current.config
userpatches/linux-rockchip64-edge.config
userpatches/linux-rk35xx-vendor.config
```

分别对应：

| 文件 | 对应分支 |
|---|---|
| `linux-rockchip64-current.config` | `current` |
| `linux-rockchip64-edge.config` | `edge` |
| `linux-rk35xx-vendor.config` | `vendor` |

这些文件用于给不同内核分支提供基础配置。

重点关注功能：

- LXC / Docker 容器
- 网络命名空间
- bridge / veth / tun
- nftables / iptables / ipset
- PPPoE
- Realtek 2.5G 网卡
- USB 4G 网卡
- 蓝牙 / WiFi
- OverlayFS
- Android Binder
- GPU / NPU / VPU 相关能力

如果某些配置项在某个内核分支中不存在，构建系统会在内核配置阶段自动忽略或调整。

---

## 十、红外与蓝牙支持

外设扩展文件：

```text
userpatches/extensions/easepi-r2-peripherals.sh
```

overlay 文件目录：

```text
userpatches/overlay/easepi-r2-peripherals/
```

默认会尝试加入：

- AP6255 蓝牙 UART attach 服务
- 红外 keymap 加载服务
- 基础蓝牙工具包
- 红外工具包

蓝牙默认使用：

```text
/dev/ttyS9
```

如果实际系统中的蓝牙 UART 设备不是 `/dev/ttyS9`，需要修改：

```text
userpatches/overlay/easepi-r2-peripherals/usr/local/sbin/bluetooth-hciattach.sh
```

红外 keymap 默认只是模板，需要上板后用以下命令采集实际遥控器码值：

```bash
ir-keytable -t
```

然后修改：

```text
/etc/rc_keymaps/easepi_remote
```

---

## 十一、只测试设备树

如果只是想快速测试 DTB 是否能编译，不需要完整编译镜像，可以执行：

```bash
./compile.sh kernel-dtb BOARD=easepi-r2 BRANCH=current
```

测试 vendor 分支：

```bash
./compile.sh kernel-dtb BOARD=easepi-r2 BRANCH=vendor
```

测试 edge 分支：

```bash
./compile.sh kernel-dtb BOARD=easepi-r2 BRANCH=edge
```

---

## 十二、调整内核配置

如果需要进入内核配置菜单：

```bash
./compile.sh kernel-config BOARD=easepi-r2 BRANCH=current
```

vendor 分支：

```bash
./compile.sh kernel-config BOARD=easepi-r2 BRANCH=vendor
```

edge 分支：

```bash
./compile.sh kernel-config BOARD=easepi-r2 BRANCH=edge
```

调整完成后，根据构建日志提示保存到对应的 `userpatches/linux-xxx.config` 文件。

---

## 十三、镜像输出位置

编译完成后，镜像一般会输出到：

```text
output/images/
```

可以查看：

```bash
ls -lh output/images/
```

常见文件类似：

```text
Armbian-unofficial_*.img.xz
```

解压后可以使用 `dd`、balenaEtcher、Rufus 等工具写入 TF 卡或其他启动介质。

Linux 下写入示例：

```bash
xz -dk Armbian-unofficial_*.img.xz
sudo dd if=Armbian-unofficial_*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

请务必确认 `/dev/sdX` 是目标 TF 卡或 U 盘，不要写错磁盘。

---

## 十四、首次启动后建议检查

启动后建议先检查系统信息：

```bash
uname -a
cat /etc/os-release
cat /etc/armbian-release
```

检查设备树：

```bash
cat /proc/device-tree/model
```

检查网卡：

```bash
ip link
lspci
lspci | grep -i realtek
```

检查存储：

```bash
lsblk
dmesg | grep -i mmc
dmesg | grep -i nvme
dmesg | grep -i sata
```

检查 GPU：

```bash
ls /dev/dri
dmesg | grep -i -E "panthor|panfrost|mali"
```

检查 NPU：

```bash
dmesg | grep -i -E "rknpu|npu"
ls /dev | grep -i npu
```

检查蓝牙：

```bash
systemctl status bluetooth
systemctl status bluetooth-hciattach
bluetoothctl list
```

检查红外：

```bash
systemctl status ir-keymap
ir-keytable
```

---

## 十五、常见问题

### 1. current 能编译，vendor 不能编译怎么办？

vendor 分支和 current 分支使用的内核源码、DTS include、驱动节点可能不同。

建议先只编译 DTB：

```bash
./compile.sh kernel-dtb BOARD=easepi-r2 BRANCH=vendor
```

根据报错判断是 DTS include 缺失、compatible 不兼容，还是 board config 没有正确加载。

### 2. 编译时提示找不到 `rk3588-easepi-r2.dtb`？

重点检查：

```text
userpatches/config/boards/easepi-r2.conf
userpatches/kernel/archive/rockchip64-6.18/0000.patching_config.yaml
userpatches/kernel/archive/rockchip64-6.18/dt/rk3588-easepi-r2.dts
```

确认：

```bash
BOOT_FDT_FILE="rockchip/rk3588-easepi-r2.dtb"
```

并确认设备树文件被正确复制到内核源码的 Rockchip DTS 目录。

### 3. 四个 2.5G 网口顺序不符合预期怎么办？

Linux 设备树中的 `eth_order` 不一定会自动影响系统网卡命名。

建议使用 systemd `.link` 文件或 udev 规则，根据 MAC 地址或 PCI 地址固定命名。

例如后续可以统一命名为：

```text
eth0
eth1
eth2
eth3
wlan
4g
```

也可以在系统启动后通过单独的网络初始化脚本处理。

### 4. 蓝牙不能启动怎么办？

先检查 UART 设备：

```bash
ls -l /dev/ttyS*
dmesg | grep -i bluetooth
dmesg | grep -i uart
```

然后检查服务：

```bash
systemctl status bluetooth-hciattach
journalctl -u bluetooth-hciattach -b
```

如果蓝牙 UART 不是 `/dev/ttyS9`，修改：

```text
/usr/local/sbin/bluetooth-hciattach.sh
```

或在构建前修改 overlay 中的对应文件。

### 5. 红外没有反应怎么办？

先检查内核是否识别红外设备：

```bash
ir-keytable
dmesg | grep -i ir
```

再用测试模式采集遥控器码值：

```bash
ir-keytable -t
```

根据实际码值修改：

```text
/etc/rc_keymaps/easepi_remote
```

### 6. 主线 GPU 能看到设备，但没有硬件加速怎么办？

设备树和内核节点只是基础。还需要：

- 内核包含 Panthor / Panfrost 驱动
- Mesa 版本足够新
- `/dev/dri/renderD128` 存在
- 用户加入 `render` / `video` 组
- Wayland / Xorg 图形栈正确配置

可以先检查：

```bash
ls /dev/dri
dmesg | grep -i -E "panthor|panfrost|mali"
```

### 7. NPU 设备树启用了，为什么 RKNN 不一定能用？

NPU 需要内核驱动和用户态 runtime 配合。

主线内核下是否能完整使用 RKNPU，需要看：

- 内核是否有可用 RKNPU 驱动
- `/dev/rknpu` 是否出现
- RKNN runtime 是否支持当前内核和用户态
- 模型是否为 RKNN 格式

如果目标是稳定跑 RKNN，vendor 内核通常更容易成功。

---

## 十六、建议的开发流程

推荐不要一开始就完整编译所有镜像，而是按下面顺序验证：

```text
1. 编译 current DTB
2. 编译 current minimal 镜像
3. 上板测试启动、网卡、存储
4. 测试 HDMI、USB、WiFi、蓝牙、红外
5. 再测试 vendor DTB
6. 再测试 vendor minimal 镜像
7. 最后测试 edge 分支
```

对应命令：

```bash
./compile.sh kernel-dtb BOARD=easepi-r2 BRANCH=current
bash build.sh current trixie minimal

./compile.sh kernel-dtb BOARD=easepi-r2 BRANCH=vendor
bash build.sh vendor trixie minimal

./compile.sh kernel-dtb BOARD=easepi-r2 BRANCH=edge
bash build.sh edge trixie minimal
```

---

## 十七、注意事项

1. 本套件面向 EasePi-R2 / RK3588，不适用于 RK3568 板子。
2. 主线内核和 vendor 内核的 DTS、驱动、配置项不完全相同。
3. `current` 建议作为默认分支。
4. `vendor` 更适合测试 Rockchip 官方生态能力。
5. `edge` 适合测试新内核，不建议作为稳定生产环境。
6. 蓝牙和红外 overlay 已提供基础模板，但仍建议上板实测。
7. 四网口命名建议通过 udev / systemd link 或独立脚本固定。
8. GPU / NPU / VPU 设备树启用不等于用户态功能一定完整可用。
9. 写镜像前务必确认目标磁盘路径，避免误写系统盘。
10. 修改设备树后，建议先用 `kernel-dtb` 测试，再完整编译镜像。

---

## 十八、推荐默认命令

日常最推荐使用：

```bash
bash build.sh current trixie minimal
```

如果需要更稳一点的用户态生态，也可以尝试：

```bash
bash build.sh current bookworm minimal
```

如果重点测试 RK 官方 NPU / MPP / RGA：

```bash
bash build.sh vendor bookworm minimal
```

如果只是尝鲜新内核：

```bash
bash build.sh edge trixie minimal
```

---

## 十九、后续可继续完善的方向

后续可以继续增强：

- 固定四个 2.5G 网口命名
- 增加首次启动硬件检测脚本
- 增加 GPU / NPU / VPU 自检脚本
- 增加 OpenWrt LXC 自动部署脚本
- 增加 vendor 分支独立 DTS patch
- 增加红外遥控器真实 keymap
- 增加蓝牙型号自动检测
- 增加编译日志自动摘要
- 增加 GitHub Actions 云编译流程
- 增加 release 打包脚本

---

## 二十、快速开始

最简流程：

```bash
git clone --depth=1 https://github.com/armbian/build.git
cd build

# 将本套件的 userpatches/ 和 build.sh 放到当前目录

chmod +x build.sh
bash build.sh current trixie minimal
```

编译完成后查看：

```bash
ls -lh output/images/
```

然后将生成的 `.img.xz` 镜像写入 TF 卡或其他启动介质即可。
