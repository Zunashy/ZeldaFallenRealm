# Guide de compilation sur MSYS2
https://gitlab.com/hhromic/solarus/-/blob/docs/doc/building-msys2.md

# Guide de compilation de Solarus sur Red Hat 8.x / Cent OS 8.x / Fedora > 28


1. Cloner le repo courant (soyez root)

```
sudo su -
cd /home/<username>
git clone https://gitlab.com/solarus-games/solarus.git
cd solarus
```

2. Installer les pré-requis (beaaaaucoup de paquets)
```
dnf install SDL2 SDL2-devel SDL2_image-devel glm-devel SDL2_ttf-devel lua luajit luajit-devel openal openal-devel physfs physfs-devel gcc cmake qt5 qt5-devel qt-devel vorbis-tools libvorbis-devel libmodplug libmodplug-devel
```

3. Create build directory
```
mkdir build
cd build
```

4. Compile.. and Install
```
cmake ..
make install
```

5. Launch solarus
```
./solarus-run
```