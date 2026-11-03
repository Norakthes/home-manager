{ lib
, stdenv
, requireFile
, autoPatchelfHook
, makeWrapper
, patchelf
, libx11
, libxext
, libxrender
, libxtst
, libxi
, libxrandr
, libxinerama
, libxcursor
, libxfixes
, libxxf86vm
, libxt
, libGL
, mesa
, libdrm
, motif
, glib
, zlib
, gtk3
, pango
, cairo
, gdk-pixbuf
, atk
, freetype
, fontconfig
, dbus
, nss
, nspr
, alsa-lib
, cups
, expat
, udev
, libxcrypt-legacy
, gdbm
, ncurses
, readline
, tk
, tcl
, tbb
, gsettings-desktop-schemas
, glib-networking
}:

stdenv.mkDerivation rec {
  pname = "maple";
  version = "2025.0";

  src = requireFile {
    name = "Maple2025.0LinuxX64Installer.run";
    url = "https://www.maplesoft.com/";
    sha256 = "sha256-YiOqvPXRA1P/zZFGSw6capKfdqtoGbU1J+UJ7QnUoKw=";
    message = ''
      Maple installer not found in Nix store.

      Please:
      1. Download Maple 2025 installer from Maplesoft
      2. Add it to the Nix store:
         nix-store --add-fixed sha256 ~/Downloads/Maple2025.0LinuxX64Installer.run
      3. Rebuild your system
    '';
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    patchelf
  ];

  buildInputs = [
    libx11
    libxext
    libxrender
    libxtst
    libxi
    libxrandr
    libxinerama
    libxcursor
    libxfixes
    libxxf86vm
    libxt
    motif
    libGL
    mesa
    libdrm
    glib
    zlib
    gtk3
    pango
    cairo
    gdk-pixbuf
    atk
    freetype
    fontconfig
    dbus
    nss
    nspr
    alsa-lib
    cups
    expat
    stdenv.cc.cc.lib
    libxcrypt-legacy
    gdbm
    ncurses
    readline
    tk
    tcl
    tbb
    gsettings-desktop-schemas
    glib-networking
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libgdbm_compat.so.4"
    "libpanelw.so.6"
    "libsundials_sunmatrixdense.so.3"
    "libmx.so"
    "libeng.so"
    "libtbb.so.12"
    "libreadline.so.7"
    "libavcodec.so.54"
    "libavformat.so.54"
    "libavcodec.so.56"
    "libavformat.so.56"
    "libavcodec.so.57"
    "libavformat.so.57"
    "libavcodec.so.58"
    "libavformat.so.58"
    "libavcodec.so.59"
    "libavformat.so.59"
    "libavcodec.so.60"
    "libavformat.so.60"
    "libavcodec-ffmpeg.so.56"
    "libavformat-ffmpeg.so.56"
  ];

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    cp $src installer.run
    chmod u+w installer.run
    chmod +x installer.run

    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} installer.run

    export LD_LIBRARY_PATH="${lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"

    cat > installer.properties << PROPS
    mode=unattended
    installdir=$out/maple
    desktopshortcut=0
    configureMATLAB=0
    enableUpdates=0
    checkForUpdatesNow=0
    PROPS

    echo "Starting Maple installation..."
    echo "This may take 10-15 minutes, please be patient."
    echo ""

    ./installer.run \
      --optionfile installer.properties \
      --unattendedmodeui minimal \
      --debuglevel 4

    if [ ! -d "$out/maple" ] || [ -z "$(ls -A $out/maple 2>/dev/null)" ]; then
      echo "ERROR: Installation failed"
      exit 1
    fi

    echo ""
    echo "Installation complete. Creating license symlink and wrappers..."

    # The license lives outside the store (/etc/maple) so it can change without a rebuild
    rm -rf $out/maple/license
    mkdir -p $out/maple/license
    ln -s /etc/maple/license.dat $out/maple/license/license.dat

    mkdir -p $out/bin

    if [ -d "$out/maple/bin" ]; then
      for binary in $out/maple/bin/*; do
        if [ -f "$binary" ] && [ -x "$binary" ]; then
          binary_name=$(basename "$binary")
          makeWrapper "$binary" "$out/bin/$binary_name" \
            --prefix LD_LIBRARY_PATH : "$out/maple/lib:${lib.makeLibraryPath buildInputs}" \
            --prefix PATH : "$out/maple/bin" \
            --set MAPLE "$out/maple" \
            --set LM_LICENSE_FILE "/etc/maple/license.dat" \
            --set MAPLE_LICENSE_FILE "/etc/maple/license.dat" \
            --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}" \
            --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}" \
            --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules"
        fi
      done
    else
      echo "ERROR: $out/maple/bin not found"
      exit 1
    fi

    mkdir -p $out/share/applications
    cat > $out/share/applications/maple.desktop << DESKTOP
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Maple ${version}
    Comment=Advanced Mathematics Software
    Exec=$out/bin/xmaple
    Icon=$out/maple/bin/MapleIcon.png
    Terminal=false
    Categories=Education;Science;Math;
    MimeType=application/x-maple-worksheet;application/x-maple-workbook;
    StartupNotify=true
    DESKTOP

    mkdir -p $out/share/mime/packages
    cat > $out/share/mime/packages/maple.xml << MIME
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/x-maple-worksheet">
        <comment>Maple Worksheet</comment>
        <glob pattern="*.mw"/>
        <glob pattern="*.mws"/>
      </mime-type>
      <mime-type type="application/x-maple-workbook">
        <comment>Maple Workbook</comment>
        <glob pattern="*.maple"/>
      </mime-type>
    </mime-info>
    MIME

    echo "Desktop entry created"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Maple - mathematical computing environment";
    homepage = "https://www.maplesoft.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
