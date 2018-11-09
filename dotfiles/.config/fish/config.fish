# empty greeting
set fish_greeting

# powerline
set fish_function_path $fish_function_path /usr/share/powerline/bindings/fish
powerline-setup

# enable `conda activate`
source /home/tobii.intra/elin/miniconda3/etc/fish/conf.d/conda.fish

# setup cuda paths
set PATH /usr/local/cuda-9.1/bin $PATH
set LD_LIBRARY_PATH /usr/local/cuda-9.1/lib64 $LD_LIBRARY_PATH
