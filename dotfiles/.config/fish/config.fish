set fish_greeting

# setup cuda paths
set PATH /usr/local/cuda-9.1/bin $PATH
set LD_LIBRARY_PATH /usr/local/cuda-9.1/lib64 $LD_LIBRARY_PATH

# added by Miniconda3 installer
set PATH /home/tobii.intra/elin/miniconda3/bin $PATH

# powerline
set fish_function_path $fish_function_path /usr/share/powerline/bindings/fish
powerline-setup
