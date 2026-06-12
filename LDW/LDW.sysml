package LDW {
	doc /* LDW: Line Departure Warning - 車線逸脱警報 */
	doc /* LDWの要求とLDWを構成する機能およびそのつながりを含む */
	private import ScalarValues::*;

	package Requirements {
		requirement '事故の予防' {
			doc /*事故の発生を未然に防ぎたい*/
			requirement '車線逸脱による事故の予防' {
				doc /*車線逸脱による事故の発生を未然に防ぎたい*/
			}
		}
		requirement '意図しない車線逸脱の予防' {
			doc /*意図しない車線逸脱の発生を未然に防ぎたい*/
			dependency '意図しない車線逸脱の予防' to '事故の予防'::'車線逸脱による事故の予防';
		}
		requirement '車線逸脱防止' {
			doc /*運転者が意図しない車線逸脱を防ぎたい*/
			dependency '車線逸脱防止' to '意図しない車線逸脱の予防';
		}
	}

	// Actions
	action '外界の映像を撮る' {
		in '外界';
		out '映像' : ADAS::Items::'映像';
	}
	action 'レーンモデルを生成する' {
		doc /*車両に対するレーンを検出する*/
		in 'カメラ映像' : ADAS::Items::'映像';
		in 'カメラ画角' : ADAS::Items::'画角';
		out 'モデル' : ADAS::Items::'レーンモデル';
		action '鳥観図に変換する' {
			doc /*射影変換によりカメラ画像から鳥観図を作成する*/
		}
		action 'レーンを検出する' {
			doc /*カメラ画像をフィルタしてレーン部分を検出する*/
		}
		action 'レーン形状を検出する' {
			doc /*レーン部分を元に曲線モデルをあてはめてレーン形状を検出する*/
		}
		action 'レーンを推定する' {
			doc /*時系列フィルタを用いてレーンを推定する*/
		}
	}
	action 'LDWの作動を判定する' {
		in '車速' : Real;
		in '方向指示状態' : ADAS::Parts::'方向指示器'::'指示状態';
		in 'ハザード状態' : ADAS::Parts::'警告灯'::'警告状態';
		in 'LDW設定' : Boolean;
		out '判定結果' : Boolean;
	}
	action '車線逸脱を予測する' {
		in 'LDW判定' : Boolean;
		in 'モデル' : ADAS::Items::'レーンモデル';
		in '車両寸法';
		out '警報' : Boolean;
	}
	action '車線逸脱を警告する' {
		in '警報' : Boolean;
		out '警告音' : Boolean;
		out '警告灯' : Boolean;
	}
	// Flows
	flow '外界の映像を撮る'.'映像' to 'レーンモデルを生成する'.'カメラ映像';
	flow 'レーンモデルを生成する'.'モデル' to '車線逸脱を予測する'.'モデル';
	flow 'LDWの作動を判定する'.'判定結果' to '車線逸脱を予測する'.'LDW判定';
	flow '車線逸脱を予測する'.'警報' to '車線逸脱を警告する'.'警報';
}
