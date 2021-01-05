## Partitioning

1. Create a new GPT, with a 512M `EF00` partition for `/boot`, a `$RAM_SIZE` `8200` partition for `swap` and use the rest of the space for `/` as `8300`

    ```sh
    $ gdisk /dev/nvme1n1
    ```

## Encryption

1. Create the LUKS container on the second partition. Replace the cipher and key size with the best performing and secure ones from `cryptsetup benchmark`

    ```sh
    $ cryptsetup --verbose --cipher aes-xts-plain64 --key-size 256 luksFormat /dev/nvme1n1p3
    ```

1. Open the encrypted container

    ```sh
    $ cryptsetup open /dev/nvme1n1p3 luks
    ```

## Filesystems

1. Create the root filesystem, the swap filesystem and the boot filesystem

    ```
    $ mkfs.btrfs /dev/mapper/luks
    $ mkfs.fat -F32 /dev/nvme1n1p1
    $ mkfs.ext2 -L swap /dev/nvme1n1p2 1M
    ```

1. Mount the root filesystem

    ```
    $ mount -o compress=zstd:2 /dev/mapper/luks /mnt
    ```

1. Mount the boot partition

    ```
    $ mkdir /mnt/boot
    $ mount /dev/nvme1n1p1 /mnt/boot
    ```

> If dual booting with Windows...

1. Mount the Windows EFI partition

    ```
    $ mkdir -p /mnt/boot/efi
    $ mount -t vfat /dev/nvme0n1p2 /mnt/boot/efi
    ```

1. Ensure the right EFI partition was mounted

    ```
    $ ls /mnt/boot/efi/EFI/
    Boot/  Microsoft/
    ```

## Installation

1. Install the base system

    ```
    $ pacstrap /mnt base base-devel linux linux-firmware btrfs-progs
    ```

1. Enable encrypted swap that gets reset on boot using `/etc/crypttab`

    ```
    $ echo "swap     LABEL=swap  /dev/urandom  swap,offset=2048,cipher=aes-xts-plain64,size=512" >> /mnt/etc/crypttab
    ```

1. Generate the `/etc/fstab`

    ```
    $ genfstab -pU /mnt >> /mnt/etc/fstab
    $ sed -i 's/relatime/noatime/g' /mnt/etc/fstab
    $ echo "/dev/mapper/swap  none   swap    defaults   0       0" >> /mnt/etc/fstab
    ```

1. `chroot` into the new system

    ```
    $ arch-chroot /mnt
    ```

1. Set up locale stuff

    ```
    $ echo 'en_GB.UTF-8 UTF-8' > /etc/locale.gen
    $ echo 'LANG="en_GB.UTF-8"' > /etc/locale.conf
    $ echo 'KEYMAP=uk' > /etc/vconsole.conf
    $ locale-gen
    ```

1. Set up the date and time stuff

    ```
    $ ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
    $ hwclock --systohc
    ```

1. Set the machine's hostname

    ```
    $ echo <your-hostname> > /etc/hostname
    ```

1. Set up `/etc/hosts` (TODO)

    ```
    $ echo "127.0.0.1      localhost" >> /etc/hosts
    $ echo "::1            localhost" >> /etc/hosts
    $ echo "127.0.1.1      <your-hostname>.localdomain    <your-hostname>" >> /etc/hosts
    ```

1. Install some basic software

    ```
    $ pacman -S nano python zsh zsh-completions networkmanager openssh
    $ systemctl enable NetworkManager
    $ systemctl enable sshd
    ```

1. Set up the root user

    ```
    $ passwd
    ```

1. Set up your user

    ```
    $ useradd -m -G wheel -s /usr/bin/zsh <username>
    $ passwd <username>
    ```

1. Setup up sudo to allow passwordless authentication

    ```
    $ EDITOR=nano visudo
    ```

1. Install `systemd-boot` to the `/boot` partition

    ```
    $ bootctl --path=/boot install
    ```

1. Add `sd-encrypt` hook to `/etc/mkinitcpio.conf`, and replace the BusyBox init options with `systemd` ones. Make sure `sd-encrypt` comes after `block` but before `filesystems`

    ```
    HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)
    $ mkinitcpio -p linux
    ```

1. Get the UUID of the root partition

    ```
    blkid -s UUID -o value /dev/nvme1n1p3
    ```

1. Configure the Arch Linux boot loader entry (`/boot/loader/entries/arch.conf`)

    ```
    title	Arch Linux
    linux	/vmlinuz-linux
    initrd	/initramfs-linux.img
    options rd.luks.name=<YOUR-PARTITION-UUID>=luks rd.luks.options=allow-discards root=/dev/mapper/luks rw
    ```

## Cleanup

1. Exit the chroot

    ```
    $ exit
    ```

1. Unmount the filesystems

    ```
    $ umount -R /mnt
    ```
