package LDP {
	doc /* LDP: Lane Departure Prevention - 車線逸脱防止 */
	doc /* LDWに対するLDPの差分機能およびそれらのつながりを含む */
	private import ScalarValues::*;

	// Actions
	action '車両操作量を算出する' {
		in 'LDP有効' : Boolean;
		in 'モデル' : ADAS::Items::'レーンモデル';
		in '車両寸法';
		in '実車速' : Real;
		in '実角度' : Real;
		out '目標角度' : Real;
		out '目標車速' : Real;
	}
	action 'ステアリング角を設定する' {
		in '目標角度' : Real;
	}
	action '目標車速を設定する' {
		in '目標車速' : Real;
	}
	// Flows
	flow '車両操作量を算出する'.'目標角度' to 'ステアリング角を設定する'.'目標角度';
	flow '車両操作量を算出する'.'目標車速' to '目標車速を設定する'.'目標車速';
}
