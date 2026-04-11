# LDW(Lane Departure Warning): 車線逸脱警報

## 目的（Purposes）
- 運転者が意図せず走行車線から逸脱しそうな場合に注意を促し、事故を未然に防ぐ

## 要求（Requirements）
- 事故の予防
	- 車線逸脱による事故
		- 反対車線にはみ出して、対向車と正面衝突する
		- ガードレールなどがない道路で、田んぼや畑、崖下に落ちてしまう
		- ガードレールなどがない道路で、民家の一部を破損してしまう
		- 路肩を歩いている歩行者と接触して怪我を負わせてしまう
		- 複数車線の道路で、隣の車線を走る車と接触してしまう
- 意図しない車線逸脱の予防
- 車線逸脱防止

## 機能（Functions）
- 外界の映像を取得する
	- out
		- 画像
- レーンモデルを生成する
	- in
		- 画角
		- 画像
	- out
		- レーンモデル
	- sub-functions
		- 鳥瞰図に変換する
			- doc: 射影変換によりカメラ画像から鳥瞰図を作成する
		- レーンを検出する
			- doc: カメラ画像をフィルタしてレーン部分を検出する
		- レーン形状を検出する
			- doc: レーン部分を元に曲線モデルをあてはめてレーン形状を検出する
		- レーンを推定する
			- doc: 時系列フィルタを用いてレーンを推定する
- LDWの作動を判定する
	- in
		- 車速
		- 方向指示器状態
		- 非常点滅灯状態
		- LDWスイッチ状態
	- out
		- LDW-on/off
	- spec
		- 車速が60km/h以上
		- 方向指示器を作動させていない
		- 非常点滅灯を作動させていない
		- LDWがONになっている
- 車線逸脱を予測する
	- in
		- LDW-on/off
		- レーンモデル
		- 車両寸法
	- out
		- 警報-on/off
- 車線逸脱を警告する
	- 警告灯を点灯する
	- 警報音を鳴らす
- 車線逸脱の警告を停止する
	- 警告灯を消灯する

## 構成
- フロントカメラ
- 画像解析装置
- 方向指示器
- 非常点滅灯
- MFD
	- 警告灯
	- 警報ブザー
- ハンドルスイッチ

## 参考
- [LDW（車線逸脱警報）について](https://www.nissan.co.jp/OPTIONAL-PARTS/NAVIOM/LEAF_SPECIAL/1709/PG/guid-824c5ddd-aebf-4b16-9b94-7d8f36da6539.html)
- [アウトランダー 取扱説明書](https://www.mitsubishi-motors.co.jp/afterservice/manual/html/outlander_manual/07-04-17.html)
- [車線逸脱警報システム（LDW）の効果的な活用と注意点](https://media.notice-myself.com/5271/)
- [ADAS(エーダス・先進運転支援システム)とは？自動運転との違いは？](https://www.nec-solutioninnovators.co.jp/ss/mobility/column/11/index.html)
- [車線逸脱警告システムにおけるレーン検出の仕組み](https://news.mynavi.jp/techplus/article/computer_vision-24/)

# LDP(Lane Departure Prevention): 車線逸脱防止支援
## 目的（Purpose）
- 運転者が意図せず走行車線から逸脱しそうな場合に注意を促し、事故を未然に防ぐ

## 機能（Functions）
- 車両操作量を算出する
	- in
		- LDW-on/off
		- レーンモデル
		- 車両寸法
		- 車速
		- ステアリング操作角
		- 車両操作量
			- ステアリング操作量
			- 現在速度
	- out
		- ステアリング操作量
		- 目標速度
- ステアリング角を設定する
- 目標速度を設定する

## 構成
- フロントカメラ
- 画像解析装置
- 方向指示器
- 非常点滅灯
- MFD
	- 警告灯
	- 警報ブザー
- ハンドルスイッチ
- パワーステアリング
- 車速コントローラ
