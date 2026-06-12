package FCW {
	doc /* FCW(Forward Collision Warning): 前方衝突警報 */
	doc /* FCWを構成する機能およびそのつながりを含む */
	private import ScalarValues::*;

	// Actions
	action '外界の映像を撮る' subsets LDW::'外界の映像を撮る' {
		doc /* 前方障害物との距離はレーダーやLiDARでも測定できるが、ここでは２眼レンズのカメラを使用する */
		in '外界'[2] : ADAS::Items::'外界';
		out '映像'[2] : ADAS::Items::'映像';
	}
	action '前方障害物との距離を推定する' {
		in 'カメラ映像'[2] : ADAS::Items::'映像';
		out '前方障害物距離' : Integer;
	}
	action 'FCWの作動を判定する' {
		in 'FCW設定' : Boolean;
		in '前方障害物距離' : Integer;
		out '警報' : Boolean;
	}
	action '前方衝突を警告する' {
		in '警報' : Boolean;
		out '警告音' : Boolean;
		out '警告灯' : Boolean;
	}
	// Flows
	flow '外界の映像を撮る'.'映像' to '前方障害物との距離を推定する'.'カメラ映像';
	flow '前方障害物との距離を推定する'.'前方障害物距離' to 'FCWの作動を判定する'.'前方障害物距離';
	flow 'FCWの作動を判定する'.'警報' to '前方衝突を警告する'.'警報';
}
