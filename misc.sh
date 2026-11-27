alias pps='podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.CreatedHuman}}\t{{.Image}}\t{{.Ports}}"'
source ~/.bashrc

hostname -I
