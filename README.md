# Airryr

https://github.com/kurain/co2mini を利用し、Mackerel と連携した二酸化炭素濃度監視bot

## environment

* Ruby 2.5.1
* bundler 1.16.4

## 機能

Mackerel のサービスメトリックに二酸化炭素濃度と気温をPOSTし続けます。

![service_metric](https://user-images.githubusercontent.com/5991227/68680366-e56b2080-05a4-11ea-9c63-2a51d5c5844b.png)

Mackerel 側の各種インテグレーションやWebhook 通知と連携することで、君だけの最強換気システムを構築しよう！
twitterで怒ってほしいときは、Mackerel のWebhook 通知を受け取ってtwitter でリプライを飛ばさせるsinatraアプリケーション https://github.com/jyllsarta/airryr_web をどうぞ。

## 前提となる環境構築

https://github.com/kurain/co2mini が動作する環境を用意します。

https://github.com/kurain/co2mini/blob/master/README を参考に作業するとよいでしょう。

### install libraries

```shell
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

### setup

```shell
git clone https://github.com/jyllsarta/airryr.git
cd airryr
bundle install
```

### edit .env

```shell
cp dotenv.example .env
vim .env
```

```diff
- MACKEREL_SERVICE_NAME=xxxxxxxx
- MACKEREL_API_KEY=XxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx
+ MACKEREL_SERVICE_NAME=your_mackerel_service_name
+ MACKEREL_API_KEY=YoUrMaCkErElApIkEy00000000000000000000000000
```

### 動作確認

デバイスから一度だけデータを取得し、即座にMackerelのサービスメトリックにPOSTします。

```shell
bundle exec ruby post_co2_once.rb
```

### run

なにかあるまで永遠にデータを取得し続け、SEND_INTERVAL_SECONDS(デフォルト2分)毎にまとめてMackerelにPOSTします。

デバイスから飛んでくるであろう何かしらのエラーに対するハンドリングが必要なはずですが、3日ほど運用して全くコケずに元気に値を送信し続けてくれてしまっているので逆に困っています。
ログは標準出力に垂れ流すので、何かあった場合に備えてエラー出力とまとめてリダイレクトすると良いでしょう。

```shell
bundle exec ruby airryr.rb &>> airryr.log &
```
