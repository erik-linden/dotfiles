# empty greeting
set fish_greeting

# conda python, append instead of prepend to keep system interpreter
set PATH $PATH /home/tobii.intra/elin/miniconda3/bin

# enable `conda activate`
source /home/tobii.intra/elin/miniconda3/etc/fish/conf.d/conda.fish

# powerline, must be after conda
set fish_function_path $fish_function_path /usr/share/powerline/bindings/fish
powerline-setup

# setup cuda paths
set PATH /usr/local/cuda-9.1/bin $PATH
set LD_LIBRARY_PATH /usr/local/cuda-9.1/lib64 $LD_LIBRARY_PATH
