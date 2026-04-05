
package LDW {
	package Requirements {
		requirement '事故の予防' {
			doc /*事故の発生を未然に防ぎたい*/
			requirement '車線逸脱による事故の予防' {
				doc /**/
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
	package Items {
		item def Scene;				//外界
		item def Picture;			//画像
		item def ViewAngle;			//カメラ画角
		item def VehicleDemension;	//車両寸法
		enum def TurnSignal {		//方向指示器
			off;
			right;
			left;
		}
		enum def HazardLight {		//非常点滅灯
			off;
			on;
		}
		enum def LDWState {			//LDW
			off;
			on;
		}
	}
	package Functions {
		private import ScalarValues::*;
		private import ModelingMetadata::*;

		action '外界の映像を取得する' {
			in scene : Items::Scene;
			out picture : Items::Picture;
		}
		action '意図しない車線逸脱を検知する' {
			dependency '意図しない車線逸脱を検知する' to LDW::Requirements::'車線逸脱防止';
			in vangle : Items::ViewAngle;
			in dimension : Items::VehicleDemension;
			in picture : Items::Picture;
			in speed : Real;
			in turn : Items::TurnSignal;
			in hazard : Items::HazardLight;
			in ldwstate : Items::LDWState;
			out deviation : Boolean;

			bind 'レーンを検出する'.picture = picture;
			bind 'レーンを検出する'.vangle = vangle;
			bind 'LDWの作動を判定する'.speed = speed;
			bind 'LDWの作動を判定する'.turn = turn;
			bind 'LDWの作動を判定する'.hazard = hazard;
			bind 'LDWの作動を判定する'.ldw_state = ldwstate;
			bind '車線逸脱を予測する'.dimension = dimension;
			bind deviation = '車線逸脱を予測する'.deviation;

			item def LaneModel;

			action 'レーンを検出する' {
				doc /*車両に対するレーンを検出する*/
				in picture : Items::Picture;
				in vangle : Items::ViewAngle;
				out lane_model : LaneModel;
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
			action 'LDWの作動を判定する' : Boolean {
				in speed : Real;
				in turn : Items::TurnSignal;
				in hazard : Items::HazardLight;
				in ldw_state : Items::LDWState;
				out enable : Boolean;
			}
			action '車線逸脱を予測する' {
				in lane_model : LaneModel;
				in dimension : Items::VehicleDemension;
				out deviation : Boolean;
			}
			flow 'レーンを検出する'.lane_model to '車線逸脱を予測する'.lane_model;
			first start;
			then 'レーンを検出する';
			if 'LDWの作動を判定する' == true
				then '車線逸脱を予測する';
		}
		action '車線逸脱を警告する' {
			dependency '意図しない車線逸脱を検知する' to LDW::Requirements::'車線逸脱防止';
			action '警告灯を点灯する' {
				terminate;
			}
			action '警報音を鳴らす' {
				terminate;
			}
			first start;
			then fork f1;
				then '警告灯を点灯する';
				then '警報音を鳴らす';
		}
		action '車線逸脱の警告を停止する' {
			dependency '車線逸脱の警告を停止する' to '車線逸脱を警告する';
			action '警告灯を消灯する' {
				terminate;
			}
			first start;
			then '警告灯を消灯する';
		}
		action 'LDWをONにする';
		action 'LDWをOFFにする';
		action '方向指示器を右折にする';
		action '方向指示器を左折にする';
		action '方向指示器をOFFにする';
		action '非常点滅灯をONにする' {
			out hz : Items::HazardLight;
		}
		action '非常点滅灯をOFFにする' {
			out hz : Items::HazardLight;
		}
	}
	package Structure {
		package Ports {
			port def TurnSignal {
				out item tsig : Items::TurnSignal;
			}
			port def HazardLight {
				out item hz : Items::HazardLight;
			}
			port def LDWSwitchSignal {
				out item sw : Items::LDWState;
			}
			port def LDWMessage {
			}
		}

		part LDW {
			part 'フロントカメラ' {
				perform action '外界の映像を取得する';
			}
			part '画像解析装置' {
				attribute view_angle : Items::ViewAngle;
				attribute vh_dimension : Items::VehicleDemension;
				attribute ldw_state : Items::LDWState;
				port tsig_port : ~Ports::TurnSignal;
				port hz_port : ~Ports::HazardLight;
				port ldwsw_port : ~Ports::LDWSwitchSignal;
				port dev_port : Ports::LDWMessage;
				perform action '意図しない車線逸脱を検知する';
			}
			part '方向指示器' {
				port tsig_port : Ports::TurnSignal;
				perform action '方向指示器を右折にする';
				perform action '方向指示器を左折にする';
				perform action '方向指示器をOFFにする';
			}
			part '非常点滅灯' {
				port hz_port : Ports::HazardLight;
				perform action '非常点滅灯をONにする';
				perform action '非常点滅灯をOFFにする';
			}
			part MFD {
				perform action '車線逸脱を警告する';
				perform action '車線逸脱の警告を停止する';	
			}
			part 'ハンドルスイッチ' {
				port ldwsw_port : Ports::LDWSwitchSignal;
				perform action 'LDWをONにする';
				perform action 'LDWをOFFにする';
			}
		}
	}
}
