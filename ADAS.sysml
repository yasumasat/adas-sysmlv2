package ADAS {
	doc /* ADASの構成要素とそれらの振る舞いおよびつながりを含む */
	private import ScalarValues::*;

	package Items {
		item def '外界';
		item def '映像';
		item def '画角';
		item def 'レーンモデル';
	}
	package Parts {
		part def 'ブザー' {
			enum def '音状態' { OFF; ON; }
			attribute '状態' : '音状態';
			action 'ブザーを鳴らす' {
				assign '状態' := '音状態'::ON;
			}
			action 'ブザーを止める' {
				assign '状態' := '音状態'::OFF;
			}
		}
		part def '警告灯' {
			enum def '警告状態' { OFF; ON; }
			attribute '警告' : '警告状態';
			action '警告灯をONにする' {
				assign '警告' := '警告状態'::ON;
			}
			action '警告灯をOFFにする' {
				assign '警告' := '警告状態'::OFF;
			}
		}
		part def '方向指示器' {
			enum def '指示状態' { OFF; '右折'; '左折'; }
			attribute '指示位置' : '指示状態';
		}
		part def 'OnOffスイッチ' {
			enum def 'スイッチ状態' { OFF; ON; }
			attribute '状態' : 'スイッチ状態';
			action 'スイッチをONにする';
			action 'スイッチをOFFにする';
		}
	}

	part 'フロントカメラ' {
		port 'レンズ'[2];
		port '映像出力'[2];

		perform action '外界の映像を出力する' {
			action '外界取得' accept scene : Items::'外界' via 'レンズ';
			flow '外界取得'.scene to '外界の映像を撮る'.'外界';
			perform FCW::'外界の映像を撮る';
			send '外界の映像を撮る'.'映像' via '映像出力';
		}
	}
	//part 'レーダー';
	//part 'LiDAR';

	connect 'フロントカメラ'.'映像出力' to 'ADASコントローラ'.'映像入力';

	part 'ハンドルスイッチ' {
		part 'LDW制御スイッチ' : Parts::'OnOffスイッチ' {
			port 'LDW出力';
			perform action 'LDWをONにする' redefines 'スイッチをONにする' {
				assign '状態' := 'スイッチ状態'::ON;
				send '状態' via 'LDW出力';
			}
			perform action 'LDWをOFFにする' redefines 'スイッチをOFFにする' {
				assign '状態' := 'スイッチ状態'::OFF;
				send '状態' via 'LDW出力';
			}
		}
		part 'FCW制御スイッチ' : Parts::'OnOffスイッチ' {
			port 'FCW出力';
			perform action 'FCWをONにする' redefines 'スイッチをONにする' {
				assign '状態' := 'スイッチ状態'::ON;
				send '状態' via 'FCW出力';
			}
			perform action 'FCWをOFFにする' redefines 'スイッチをOFFにする' {
				assign '状態' := 'スイッチ状態'::OFF;
				send '状態' via 'FCW出力';
			}
		}
	}

	connect 'ハンドルスイッチ'::'LDW制御スイッチ'.'LDW出力' to 'ADASコントローラ'.'ADAS設定入力';
	connect 'ハンドルスイッチ'::'FCW制御スイッチ'.'FCW出力' to 'ADASコントローラ'.'ADAS設定入力';

	part 'ハザード' : Parts::'警告灯' {
		port 'ハザード状態出力';

		perform action '非常点滅灯をONにする' redefines '警告灯をONにする' {
			assign '警告' := '警告状態'::ON;
			send '警告' via 'ハザード状態出力';
		}
		perform action '非常点滅灯をOFFにする' redefines '警告灯をOFFにする' {
			assign '警告' := '警告状態'::OFF;
			send '警告' via 'ハザード状態出力';
		}
	}

	connect 'ハザード'.'ハザード状態出力' to 'ADASコントローラ'.'操作入力';

	part '方向指示器' : Parts::'方向指示器' {
		port '指示出力';

		perform action '方向指示器を右折にする' {
			assign '指示位置' := '指示状態'::'右折';
			send '指示位置' via '指示出力';
		}
		perform action '方向指示器を左折にする' {
			assign '指示位置' := '指示状態'::'左折';
			send '指示位置' via '指示出力';
		}
		perform action '方向指示器をOFFにする' {
			assign '指示位置' := '指示状態'::OFF;
			send '指示位置' via '指示出力';
		}
	}

	connect '方向指示器'.'指示出力' to 'ADASコントローラ'.'操作入力';

	part 'ADASコントローラ' {
		attribute '車両寸法';
		attribute 'カメラ画角';

		port '映像入力';
		port 'ADAS設定入力';
		port '操作入力';
		port '車両状態入力';
		port '警報出力';
		port '車両制御出力';

		perform action '前方衝突警報を判定する' {
			action '映像入力取得' accept 'カメラ映像' : Items::'映像' via '映像入力';
			flow '映像入力取得'.'カメラ映像' to FCW::'前方障害物との距離を推定する'.'カメラ映像';
			perform FCW::'前方障害物との距離を推定する';

			action 'FCW設定入力取得' accept 'FCW設定' : Boolean via 'ADAS設定入力';
			flow 'FCW設定入力取得'.'FCW設定' to FCW::'FCWの作動を判定する'.'FCW設定';
			perform FCW::'FCWの作動を判定する';

			send FCW::'FCWの作動を判定する'.'警報' via '警報出力';
		}
		perform action '意図しない車線逸脱を検知する' {
			out 'モデル' = LDW::'レーンモデルを生成する'.'モデル';
			out 'LDW有効' = LDW::'LDWの作動を判定する'.'判定結果';

			action '映像入力取得' accept 'カメラ映像' : Items::'映像' via '映像入力';
			flow '映像入力取得'.'カメラ映像' to LDW::'レーンモデルを生成する'.'カメラ映像';
			bind LDW::'レーンモデルを生成する'.'カメラ画角' = 'カメラ画角';
			perform LDW::'レーンモデルを生成する';

			action 'LDW設定入力取得' accept 'LDW設定' : Boolean via 'ADAS設定入力';
			flow 'LDW設定入力取得'.'LDW設定' to LDW::'LDWの作動を判定する'.'LDW設定';
			action '方向指示入力取得' accept '方向指示' : Parts::'方向指示器'::'指示状態' via '操作入力';
			flow '方向指示入力取得'.'方向指示' to LDW::'LDWの作動を判定する'.'方向指示状態';
			action 'ハザード入力取得' accept 'ハザード' : Parts::'警告灯'::'警告状態' via '操作入力';
			flow 'ハザード入力取得'.'ハザード' to LDW::'LDWの作動を判定する'.'ハザード状態';
			action '車速入力取得' accept '車速' : Real via '車両状態入力';
			flow '車速入力取得'.'車速' to LDW::'LDWの作動を判定する'.'車速';
			perform LDW::'LDWの作動を判定する';

			bind LDW::'車線逸脱を予測する'.'車両寸法' = '車両寸法';
			perform LDW::'車線逸脱を予測する';
			
			send '車線逸脱を予測する'.'警報' via '警報出力';
		}
		flow '意図しない車線逸脱を検知する'.'モデル' to '車線逸脱を回避する'.'モデル';
		flow '意図しない車線逸脱を検知する'.'LDW有効' to '車線逸脱を回避する'.'LDP有効';
		perform action '車線逸脱を回避する' {
			in 'モデル';
			in 'LDP有効';
			
			action '車速入力取得' accept '車速' : Real via '車両状態入力';
			flow '車速入力取得'.'車速' to LDP::'車両操作量を算出する'.'実車速';
			action '角度入力取得' accept '角度' : Real via '車両状態入力';
			flow '角度入力取得'.'角度' to LDP::'車両操作量を算出する'.'実角度';
			bind LDP::'車両操作量を算出する'.'モデル' = 'モデル';
			bind LDP::'車両操作量を算出する'.'LDP有効' = 'LDP有効';
			bind LDP::'車両操作量を算出する'.'車両寸法' = '車両寸法';
			perform LDP::'車両操作量を算出する';

			send '車両操作量を算出する'.'目標角度' via '車両制御出力';
			send '車両操作量を算出する'.'目標車速' via '車両制御出力';
		}
	}

	connect 'ADASコントローラ'.'警報出力' to 'メータパネル'.'警報入力';

	part 'メータパネル' {
		port '警報入力';

		part 'メータコントローラ' {
			perform action '前方衝突警報を通知する' {
				action '警報入力取得' accept '前方衝突警報' : Boolean via '警報入力';
				flow '警報入力取得'.'前方衝突警報' to '前方衝突を警告する'.'警報';
				perform FCW::'前方衝突を警告する';
				if '前方衝突を警告する'.'警告灯' then '前方衝突警告灯'::'警告灯をONにする';
				else '前方衝突警告灯'::'警告灯をOFFにする';
			}
			flow '前方衝突警報を通知する'::'前方衝突を警告する'.'警告音'
			to '警告ブザーを制御する'::'警告ブザーの制御を判定する'.'前方衝突警報';

			perform action '車線逸脱警報を通知する' {
				action '警報入力取得' accept '車線逸脱警報' : Boolean via '警報入力';
				flow '警報入力取得'.'車線逸脱警報' to '車線逸脱を警告する'.'警報';
				perform LDW::'車線逸脱を警告する';
				if '車線逸脱を警告する'.'警告灯' then '車線逸脱警告灯'::'警告灯をONにする';
				else '車線逸脱警告灯'::'警告灯をOFFにする';
			}
			flow '車線逸脱警報を通知する'::'車線逸脱を警告する'.'警告音'
			to '警告ブザーを制御する'::'警告ブザーの制御を判定する'.'車線逸脱警報';

			perform action '警告ブザーを制御する' {
				doc /* 1つの警告ブザーを複数の機能で制御すると、ONにした直後にOFFにすることで鳴らない or 一瞬しか鳴らないといった不具合が出るため、警告ブザーを直接制御するのは1つの機能のみとする */
				perform action '警告ブザーの制御を判定する' {
					in '車線逸脱警報' : Boolean;
					in '前方衝突警報' : Boolean;
					out 'ブザー' : Boolean;
				}
				if '警告ブザーの制御を判定する'.'ブザー' then '警告ブザー'::'ブザーを鳴らす';
				else '警告ブザー'::'ブザーを止める';
			}
		}
		part '警告ブザー' : Parts::'ブザー';
		part '前方衝突警告灯' : Parts::'警告灯';
		part '車線逸脱警告灯' : Parts::'警告灯';
	}

	connect 'ADASコントローラ'.'車両制御出力' to 'パワーステアリング'.'目標値入力';

	part 'パワーステアリング' {
		port '目標値入力';

		perform action 'ステアリング角を更新する' {
			action '目標値入力取得' accept '目標角度' : Real via '目標値入力';
			flow '目標値入力取得'.'目標角度' to 'ステアリング角を設定する'.'目標角度';
			perform LDP::'ステアリング角を設定する';
		}
	}

	connect 'ADASコントローラ'.'車両制御出力' to '車速コントローラ'.'車速入力';

	part '車速コントローラ' {
		port '車速入力';

		perform action '車速を更新する' {
			action '車速入力取得' accept '目標車速' : Real via '車速入力';
			flow '車速入力取得'.'目標車速' to '目標車速を設定する'.'目標車速';
			perform LDP::'目標車速を設定する';
		}
	}
}
