#!/bin/bash

contents_init() {
    echo "  Copying minetest.conf file to home directory"
    cp /etc/minetest/minetest.conf $MINETESTSERVER_HOME

    echo "  Main folders creation: games, worlds, mods"
    mkdir -p $MINETESTSERVER_HOME/games $MINETESTSERVER_HOME/worlds $MINETESTSERVER_HOME/mods

    echo "  Deploying minetest_game into the games folder"
    cd $MINETESTSERVER_HOME/games
    git clone https://github.com/minetest/minetest_game.git

    echo "  Deploying mods into the mods folder"
    MODS=/root/minetest_blueprint/mods/*
    cd $MINETESTSERVER_HOME/mods
    for mod in $MODS
    do
       echo "    Processing $mod mod..."
       mv $mod .
    done
}

check_default_world() {
    if [ ! -d $MINETESTWORLD_PATH ]; then 
        echo "  Default world doesn't exist, creating it for the first time"
        mkdir -p $MINETESTWORLD_PATH
        cp /root/minetest_blueprint/worlds/myworld/world.mt $MINETESTWORLD_PATH
    else
        echo "  Default world already available in this deployment"
    fi
}

MINETESTSERVER_CFG=$MINETESTSERVER_HOME/minetest.conf
MINETESTWORLD_PATH=$MINETESTSERVER_HOME/worlds/$DEFAULTWORLD
echo "Starting minetest server..."
echo "  MINETESTSERVER_HOME: $MINETESTSERVER_HOME"
echo "  SELECTED WORLD: $DEFAULTWORLD"
echo "  MINETESTSERVER_CFG: $MINETESTSERVER_CFG"
echo "  MINETESTWORLD_PATH: $MINETESTWORLD_PATH"

# 0. Build folder structure if it's the first run
echo "Step 0 - Check for first run"
if [ ! -f $MINETESTSERVER_HOME/minetest.conf ]; then 
  contents_init
fi

# 1. Check the default world status
echo "Step 1 - Check if $DEFAULTWORLD exists already"
check_default_world

# 2. Starting the server up
/usr/bin/minetestserver --config $MINETESTSERVER_CFG --world $MINETESTWORLD_PATH