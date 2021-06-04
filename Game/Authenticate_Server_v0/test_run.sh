#!/bin/bash

alias godot="D:/Godot_v3.2.3-stable_win64.exe"

godot -s addons/gut/gut_cmdln.gd -d --path $PWD -gtest=res://test/intergration/test_Authenticate./test.gd -glog=3 > result.txt
