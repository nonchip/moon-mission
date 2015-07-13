#!/bin/zsh

export MM_PATH="$(readlink -f $(dirname $0))"
export MM_REAL_ROOT="$MM_PATH/.root"
export MM_SRC="$MM_PATH/.src"
export MM_ROOT="/tmp/.mm.$(uuidgen -t)-$(uuidgen -r)"

continue_stage=n
if [ -f "$MM_PATH/.continue_stage" ]
  then continue_stage=$(cat "$MM_PATH/.continue_stage")
fi

if [ -f "$MM_PATH/.continue_root" ]
  then MM_ROOT=$(cat "$MM_PATH/.continue_root")
fi

case $continue_stage in
  n)
    rm -f "$MM_PATH/.continue_stage"
    rm -rf "$MM_ROOT" "$MM_SRC" "$MM_REAL_ROOT"
    mkdir -p "$MM_REAL_ROOT" "$MM_SRC"
    ln -s "$MM_REAL_ROOT" "$MM_ROOT"
    echo "$MM_ROOT" > "$MM_PATH/.continue_root"
    ;&
  luajit)
    echo "luajit" > "$MM_PATH/.continue_stage"
    cd $MM_SRC
    git clone http://luajit.org/git/luajit-2.0.git luajit || exit
    cd luajit
    git checkout v2.1
    git pull
    make amalg PREFIX=$MM_ROOT CPATH=$MM_ROOT/include LIBRARY_PATH=$MM_ROOT/lib && \
    make install PREFIX=$MM_ROOT || exit
    ln -sf luajit-2.1.0-alpha $MM_ROOT/bin/luajit
    ;&
  luarocks)
    echo "luarocks" > "$MM_PATH/.continue_stage"
    cd $MM_SRC
    git clone git://github.com/keplerproject/luarocks.git || exit
    cd luarocks
    ./configure --prefix=$MM_ROOT \
                --lua-version=5.1 \
                --lua-suffix=jit \
                --with-lua=$MM_ROOT \
                --with-lua-include=$MM_ROOT/include/luajit-2.1 \
                --with-lua-lib=$MM_ROOT/lib/lua/5.1 \
                --force-config && \
    make build && make install || exit
    ;&
  msgpack)
    echo "msgpack" > "$MM_PATH/.continue_stage"
    # messagepack
    $MM_ROOT/bin/luarocks install lua-messagepack || exit
    ;&
  moonscript)
    echo "moonscript" > "$MM_PATH/.continue_stage"
    $MM_ROOT/bin/luarocks install moonscript
    ;&
  wrappers)
    echo "wrappers" > "$MM_PATH/.continue_stage"
    # wrappers
    cat > $MM_PATH/.run <<END
#!/bin/zsh
export MM_PATH="\$(dirname "\$(readlink -f "\$0")")"
export MM_REAL_ROOT="\$MM_PATH/.root"
export MM_ROOT="$MM_ROOT"

[ -e "\$MM_ROOT" ] || ln -s "\$MM_PATH/.root" \$MM_ROOT

export PATH="\$MM_ROOT/bin:\$PATH"
export LUA_PATH="\$MM_PATH/custom_?.lua;\$MM_PATH/src/?/init.lua;\$MM_PATH/src/?.lua;\$MM_PATH/?.lua;\$LUA_PATH;\$MM_ROOT/lualib/?.lua;\$MM_ROOT/share/luajit-2.1.0-alpha/?.lua;\$MM_ROOT/share/lua/5.1/?.lua;\$MM_ROOT/share/lua/5.1/?/init.lua"
export LUA_CPATH="\$MM_PATH/custom_?.so;\$MM_PATH/src/?/init.so;\$MM_PATH/src/?.so;\$MM_PATH/?.so;\$LUA_CPATH;\$MM_ROOT/lualib/?.so;\$MM_ROOT/share/luajit-2.1.0-alpha/?.so;\$MM_ROOT/share/lua/5.1/?.so;\$MM_ROOT/share/lua/5.1/?/init.so"
export MOON_PATH="\$MM_PATH/custom_?.moon;\$MM_PATH/src/?/init.moon;\$MM_PATH/src/?.moon;\$MM_PATH/?.moon;\$MOON_PATH;\$MM_ROOT/lualib/?.moon;\$MM_ROOT/share/luajit-2.1.0-alpha/?.moon;\$MM_ROOT/share/lua/5.1/?.moon;\$MM_ROOT/share/lua/5.1/?/init.moon"
export LD_LIBRARY_PATH="\$MM_ROOT/lib:\$LD_LIBRARY_PATH"

fn=\$(basename \$0)
if [ "\$fn" = ".run" ]
  then exec "\$@"
else
  exec \$fn "\$@"
fi
END
    chmod a+rx $MM_PATH/.run
    ln -sf .run $MM_PATH/moon
    ;&
esac

# cleanup
rm -rf "$MM_SRC"
rm -f "$MM_ROOT" "$MM_PATH/.continue_stage" "$MM_PATH/.continue_root"
