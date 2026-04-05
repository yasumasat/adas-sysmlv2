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
- LDWを初期化する
- LDWをONにする
- LDWをOFFにする
- 意図しない車線逸脱を検知する
	- 外界の映像を取得する
	- レーンを検出する
		- 鳥瞰図に変換する
			- doc: 射影変換によりカメラ画像から鳥瞰図を作成する
		- レーンを検出する
			- doc: カメラ画像をフィルタしてレーン部分を検出する
		- レーン形状を検出する
			- doc: レーン部分を元に曲線モデルをあてはめてレーン形状を検出する
		- レーンを推定する
			- doc: 時系列フィルタを用いてレーンを推定する
	- LDWの作動を判定する
		- 車速が60km/h以上
		- 方向指示器を作動させていない
		- 非常点滅灯を作動させていない
		- LDWがONになっている
	- 車線逸脱を判定する
		- レーンが検出できている
		- 自車両の寸法
- 車線逸脱を警告する
	- 警告灯を点灯する
	- 警報音を鳴らす

## 構成
- フロントカメラ
- 画像解析装置
- 方向指示器
- 非常点滅灯
- LDWコントローラ
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
