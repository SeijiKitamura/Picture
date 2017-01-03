## はじめに
fswebcamのラッパーです。
PCに接続されているカメラ台数分だけ写真を撮影します。

## 必要なパッケージ
fswebcamを使用しています。ターミナルで以下のコマンドを実行してください。
```bash
   sudo apt-get install -y fswebcam
```

## ダウンロード
homeディレクトリに保存することを前提にしています。ターミナルで以下のコマンドを実行してください。
```bash
   cd
   git clone https://github.com/SeijiKitamura/picture.git
```

## 使い方
PCにWebカメラを指して以下のコマンドを実行してください。
```bash
   cd
   cd picture
   ./picture.sh
```
picture/public/img内に写真が保存されてます。
```bash
   cd
   ls picture/public/img
```

## 画像ファイル名規則
以下のルールでファイル名が決まります。
```
   DAY年月日時分_カメラ番号.jpg
```
年月日時分はプログラムが起動された時間です。また、カメラ番号は0から始まります。

ex)1台のカメラで2017年1月3日午前9時7分に撮影した写真
```
   DAY201701030907_video0.jpg
```

## 定点観測
あとはcronに設定すれば定点観測になります。以下はユーザー名「pi」のcron設定例です。
午前9時から午後22時まで15分間隔で撮影を行います。

```bash
   crontab -e
   */15 9-22 * * * /bin/bash /home/pi/picture/picture.sh > /dev/null 2>&1
```

## 注意点
+ PCに接続されているすべてのカメラを使って撮影を行います。
```
プログラム上、カメラの台数に制限はありません。
逆に言うとカメラを指定した撮影はできません。
```
+ 複数台カメラを接続した場合、稀に撮影に失敗します。

## カスタムインストール
### はじめに
custom_setup.shを実行すると以下のことができるようになります。
Webカメラで撮影した画像を１つのサーバーに集約する場合などに便利です。

+ Webサーバー（Apache2)
+ SCPファイル転送
+ 画像自動撮影
+ 画像削除
+ 再起動

主にRaspberry Pi用として作成しました。
これを使うことで複数のRaspberry Piで撮影した画像を1つのサーバーに
簡単に集約することができます。

### インストール方法
以下のコマンドを実行します。
```bash
   cd
   cd picture
   ./custome_setup.sh
```

### インストール内容
主に以下の設定を行います。
+ Webサーバー設定
+ SSH
+ 送信先ファイルサーバーの設定(scp)
+ 撮影スケジュール(cron)
+ 再起動スケジュール(cron)

### custom_set.upの詳細
#### 必要なパッケージのインストール
```
   fswebcam
   apache2
```

#### apache設定
```
   conf/picture.confをコピーしてブラウザから写真を確認できるようにします。
   ブラウザで「カメラPCのIPアドレス/img」と打ち込むと写真が確認できます。
   DocumentRoot は

   /home/ユーザー名/picture/public

   です。
```

#### cron(conf/cron.txt)
```
   実行ユーザーのcronに撮影スケジュールを登録します。詳細は以下のcron.txt
   を参考にしてください。
```

#### cron(conf/reboot.txt)
```
   定時にPCを再起動させます。fswebcamを使用していると稀にプログラムがカメラ
   を掴んだままになり撮影できない場合が起こります。 それを回避するために1日1回
   再起動をかけています。デフォルトでは以下のスケジュールとなっています。

   毎日午前0時

   「再起動を望まない」もしくは「時間を変更したい」場合には「sudo crontab -e」と入力
   して修正してください。
   (crontab -eの詳しい説明はインターネットで検索してください)
```

#### scpserver.ini
```
scpserver.ini.defaultをscpserver.iniにコピーし,以下の内容を登録します。

   FILESERVER=               #ファイルサーバーアドレス
   SCPUSER=                  #ファイルサーバーへのログインID
   DIR=                      #ファイルサーバー上のPath

```

#### SSHキー作成
```
   /home/ユーザー名/.sshに「id_rsa.pub」がない場合、キーを作成します。
   特にこだわりがなければエンターキー空打ちを続けると作成されます。

   SSH公開キー登録
     ini/scpserver.iniで設定した送信先サーバーに
     このPCの公開キー(id_rsa.pub)を送信して登録してください。
     詳しくはインターネットで「SSH公開キー」を検索してください。

   SSHキー送信
     ファイルサーバーにこのPCの公開キーを送信します。

   SSHキー送信
     ファイルサーバーにこのPCの公開キーを送信します。
```

### ファイル詳細
#### picture.sh
/dev/video[\*]の台数分だけ静止画を撮影します。
撮影後はpublic/imgディレクトリに「DAY年月日時分_video[\*].jpg」という名前で
保存されその後、ファイルサーバーへの送信を行います。

+ SLEEPTIME (picture.sh 変数)
  ```
  1つのカメラを撮影してから次のカメラに移るまでの時間（秒）。0にすると稀に「device busy」となり撮影に失敗します。

  ex)SLEEPTIME=3でカメラ4台接続されている場合
    video0 撮影後、3秒停止
    video1 撮影後、3秒停止
    video2 撮影後、3秒停止
    video3 撮影後、3秒停止
  ```

#### ini/video_default.ini
デフォルトのカメラ設定です。詳細はインターネットで「fswebcam option」と検索してください。

#### ini/video[0-9]*.ini
カメラごとに設定ファイルを作成することも可能です。  この場合、/dev/video と ini/video の番号が一致している必要があります。
（なければvideo_default.iniが使用されます)

#### ini/scpserver[0-9]*.ini

ファイル送信先の情報を登録するファイルです。送信先を複数台登録することも可能で、その場合はini/scpserver[任意の番号].iniファイルを
設置してください。ファイル送信を希望しない場合にはこのファイルを削除してください。

#### send.sh
撮影した写真を再度ファイルサーバーに送信します。LAN接続が切れていた等の障害発生に備えて、「何日前」から今日までの
写真を再送信します。再送信後、ここで指定した日付の写真が削除されます。

##### 変数
+ BACKDAY (send.sh 変数)
  何日前からの写真を再送信の対象とするか0以上の数字を登録します。
  ```
  ex)
  #当日の写真を再送信後、当日の写真を削除
  BACKDAY=0
   
  #3日前から今日までの写真を再送信後、3日前の写真を削除
  BACKDAY=3
  ```

#### ini/scpserver[0-9]*.ini
ファイル送信先の情報を登録するファイルです。送信先を複数台登録することも可能で、
その場合はini/scpserver[任意の番号].iniファイルを設置してください。
「picture.sh」と同じファイルを使用しています。(ファイル送信にはscpを使用しています)
なお、ファイルサーバーには以下のフォルダが用意されていることが前提となっています。

/指定したディレクトリ/年/月/日/ホスト名/デバイス名

ex)
以下の条件で撮影した場合、

```
撮影日                   2016年12月15日
ホスト名                 raspberry
デバイス名               video0
ini/scpserver.ini内のDIR /home/user/picture
```

ファイルサーバー上で必要なディレクトリは

```
/home/user/picture/2016/12/15/raspberry/video0
```

です。

注意点
```
ファイル送信に成功しても失敗してもBACKDAYで指定された写真は削除されます。
```

#### conf/cron.txt
インストール時に自動でcronに追加されます。
デフォルトでは以下のスケジュールで実行されます。

```
picture.sh  毎日午前9時から午後22時までの15分間隔
send.sh     毎日午後23時
```
このcron.txtで「picture.sh」、「send.sh」のログがsyslogに残るようになります。

#### conf/reboot.txt
インストール時に自動でcronに追加されます。
このPCの再起動スケジュールです。デフォルトでは以下のスケジュールで再起動されます。

```
毎日午前0時
```

## ファイルサーバー用
send.shで送られてくる画像を保存するためのディレクトリを作成します。
作成されるディレクトリは以下のとおりです。


### fileserver/make_dir.sh
ファイルサーバー用のディレクトリ作成プログラムです。
camera_list.txtを読み込みそこに記載されているカメラPCのホスト名ごとに
当日の日付のディレクトリを作成します。
```
年/月/日/ホスト名/デバイス名
```

#### 変数
+ MAX_VIDEO   (1台のPCに接続する最大カメラ台数。0から始まる)
+ DEV Web     (カメラのデバイス名。/devに依存)
+ CAMERA_LIST (カメラサーバーリスト)

### fileserver/camera_list.txt.default
このファイルをcamera_list.txtという名前でコピーして、そこにカメラPCの
ホスト名を記入します。記入されたホスト名のディレクトリが作成されます。

### 設置方法
+ ファイルサーバーの任意のディレクトリに上記ファイルを保存
+ camera_list.txtを作成
+ make_dir.shをcronに登録

### 例
+ ファイルサーバー保存場所 /home/user/picture
+ ファイルセット (/home/user/picture に上記2ファイルをコピー済み)
+ カメラPCが2台。ホスト名 (raspberry1 raspberry2)
+ 毎日午前0時にディレクトリ作成

```bash
# ファイルサーバー上にて
cd /home/user/picture
cp camera_list.txt.default camera_list.txt
echo "raspberry1" >> camera_list.txt
echo "raspberry2" >> camera_list.txt
./make_dir.sh
crontab -e
0 0 * * * /bin/bash /home/user/picture/make_dir.sh | logger -i -t "make_dir.sh"
```
上記コマンドでpictureディレクトリ内に今日の日付のディレクトリが作成されます。

### 注意点
カメラPCはファイルサーバーにscpでファイル送信するので、カメラPCのid_rsa.pubが
ファイルサーバーのauthorized_keysに登録済みとなっていることが前提になります。
scpやid_rsa.pubの詳細についてはインターネットで検索してください。

## ログについて
picture.sh、send.shはほとんどのメッセージを標準出力にて吐き出します。
特別ログファイルというものはありません。

また、picture.sh内で使用しているfswebcamのログは出力しない設定にしていま
す。出力したい場合はpicture.sh内fswebcamの「-q」オプションを削除し
てください。(fswebcamの詳しい設定はインターネットで検索してください。)

ログをファイルに出力したい場合には、picture.sh > logfile.txt
でlogfile.txtに出力されます。

## 仕様

### 同時撮影不可
fswebcamは同時に起動し撮影することができません。PCに複数台のカメラ
が接続されている場合、1台のカメラの撮影が終了してから、次のカメラ
の撮影が始まります。また1台のカメラの撮影に10秒前後の時間がかかり
ます。これはピント調整や露出調整の時間が必要なためです。

仮に1つのPCに10台のカメラが接続されている場合、最初のカメラが撮影
されてから最後のカメラが撮影されるまで100秒くらいかかることになり
ます。

### 撮影失敗
複数台のカメラを接続していてSLEEPTIMEに0以上の数字を設定している
にも関わらず、撮影に失敗する場合があります。

### custom_setup.shの複数回実行
cronを設定するところで既存のcronを追記して登録をかけています。
したがって、何らかの理由でcustom_setup.shを複数回実行すると同じスケジュ
ールが登録されていまうので注意が必要です。
不安なら「custom_setup.sh」を実行する前にcron部分を削除してください。


