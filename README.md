# SysML v2 system model examples using ADAS

## About this project
このプロジェクトは SysML v2を実システムに適用する方法を模索するため、ADAS（Advanced Driver-Assistance Systems:
先進運転支援システム）についての一般的な知識を元に SysML v2を用いたシステムモデルを作成します。

## The systems included
ADASは運転を支援するシステムの総称です。
xが付いたものはプロジェクトに含まれています。
既にプロジェクトに含まれているものも大幅な変更が入ることがあることに注意してください。

- [x] LDW : Lane Departure Warning（車線逸脱警報）
- [x] LDP : Lane Departure Prevention（車線逸脱防止支援）
- [x] FCW : Forward Collision Warning（前方衝突警告）
- [ ] LKAS : Lane Keeping Assist System（レーンキープ）
- [ ] ACC : Adaptive Cruise Control（オートクルーズ）
- [ ] AEBS : Advanced Emergency Braking System（衝突被害軽減）
- [ ] BSM : Blind Spot Monitoring（ブラインドモニタリング）
- [ ] NV/PD : Night Vision/Pedestrian Detection（ナイトビジョン／歩行者検知）
- [ ] TSR : Traffic Sign Recognition（道路標識認識）
- [ ] RCTA : Rear Cross Traffic Alert（後退時車両検知警報）
- [ ] DM : Driver Monitoring（ドライバモニタリング）
- [ ] AFS : Adaptive Front-lighting System（フロントライティング自動調整システム）
- [ ] APA : Advanced Parking Assist（高度駐車アシスト）

## LDW (Lane Departure Warning) : 車線逸脱警報

### 目的
- 運転者が意図せず走行車線から逸脱しそうな場合に注意を促し、事故を未然に防ぐ

### 本モデルにおける機能概要
1. フロントカメラの映像からレーンモデルを生成する
2. レーンモデルと自車両の位置と寸法から車線逸脱を予測する
3. 車線逸脱の可能性がありかつLDWの動作条件を満たしている場合は警報を出す
	- LDW設定:ON
	- 方向指示器:OFF
	- 非常警告灯（ハザード）:OFF
	- 車速:60km/h以上

### 参考
- [LDW（車線逸脱警報）について](https://www.nissan.co.jp/OPTIONAL-PARTS/NAVIOM/LEAF_SPECIAL/1709/PG/guid-824c5ddd-aebf-4b16-9b94-7d8f36da6539.html)
- [アウトランダー 取扱説明書](https://www.mitsubishi-motors.co.jp/afterservice/manual/html/outlander_manual/07-04-17.html)
- [車線逸脱警報システム（LDW）の効果的な活用と注意点](https://media.notice-myself.com/5271/)
- [ADAS(エーダス・先進運転支援システム)とは？自動運転との違いは？](https://www.nec-solutioninnovators.co.jp/ss/mobility/column/11/index.html)
- [車線逸脱警告システムにおけるレーン検出の仕組み](https://news.mynavi.jp/techplus/article/computer_vision-24/)

## LDP (Lane Departure Prevention) : 車線逸脱防止支援

### 目的
- 運転者が意図せず走行車線から逸脱しそうな場合に自動でステアリングを操作し車線逸脱による事故を未然に防ぐ

### 本モデルにおける機能概要
1. フロントカメラの映像からレーンモデルを生成する
2. レーンモデルと自車両の位置と寸法および現在速度とステアリング操作角から車線逸脱を予測する
3. 車線逸脱の可能性がありかつLDPの動作条件を満たしている場合は車線逸脱を防ぐようにステアリングを自動で操作する
	- LDP設定:ON
	- 方向指示器:OFF
	- 非常警告灯（ハザード）:OFF
	- 車速:60km/h以上

### 参考
- TBD

## FCW (Forward Collison Warning) : 前方衝突警報

### 目的
- 走行中、前を走る車両などの前方障害物に衝突しそうな場合に注意を促し、事故を未然に防ぐ

### 本モデルにおける機能概要
1. フロントカメラの映像から前方障害物との距離を計測する
2. 前方障害物との距離と車速から衝突の可能性を予測する
3. 前方障害物と衝突の危険がありかつFCWの動作条件を満たしている場合は警報を出す
	- FCW設定:ON
	- 車速:40km/h以上

## 参考
- [前方衝突警告についてさらに詳しく](https://newsmartsafe.com/industry-news/how-does-the-fcw-work)
- [インテリジェント FCW（前方衝突予測警報）について](https://www.nissan.co.jp/OPTIONAL-PARTS/NAVIOM/ARIYA_SPECIAL/2201/PG/guid-8b146a12-2f0d-4be0-b89b-cde09fa3d597.html)

## License
This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
