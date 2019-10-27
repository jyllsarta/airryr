# Airryr

https://github.com/kurain/co2mini を利用した二酸化炭素濃度監視bot

とりあえず今はデバイスから値がもらえたら標準出力に垂れ流し続けるだけです

* ログ蓄積
* しきい値を超えた際にアラートを発信

をできるようにしたい

## environment

* Ruby 2.5.1
* bundler 1.16.4

## setup environment

https://github.com/kurain/co2mini/blob/master/README を参考に作業すること

### install libraries

```shell
sudo apt-get install libhidapi-hidraw0
sudo apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool git libhidapi-hidraw0
sudo apt-get install ruby2.1 ruby2.1-dev git # rubyインストール済なら不要
sudo apt-get install usbutils
sudo vim /etc/udev/rules.d/90-co2mini.rules
```

### vim内で以下を書き込む

```shell
ACTION=="remove", GOTO="co2mini_end"

SUBSYSTEMS=="usb", KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", GROUP="plugdev", MODE="0660", SYMLINK+="co2mini%n", GOTO="co2mini_end"

LABEL="co2mini_end"

tail -2 /var/log/co2.tsv
```

## install & run

```shell
git clone https://github.com/jyllsarta/airryr.git
cd airryr
bundle install
bundle exec ruby show.rb
```
