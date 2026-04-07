
package LDW {
	private import ScalarValues::*;
	//private import ModelingMetadata::*;

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
		enum def LDWSwState {		//LDW
			off;
			on;
		}
	}
	package Functions {
		action '外界の映像を取得する' {
			in scene : Items::Scene;
			out picture : Items::Picture;
		}
		action '意図しない車線逸脱を検知する' {
			dependency '意図しない車線逸脱を検知する' to LDW::Requirements::'車線逸脱防止';
			in vangle : Items::ViewAngle;
			in picture : Items::Picture;
			in speed : Real;
			in turn : Items::TurnSignal;
			in hazard : Items::HazardLight;
			in ldwsw : Items::LDWSwState;
			in dimension : Items::VehicleDemension;
			out deviation : Boolean;

			bind 'レーンモデルを生成する'.picture = picture;
			bind 'レーンモデルを生成する'.vangle = vangle;
			bind 'LDWの作動を判定する'.speed = speed;
			bind 'LDWの作動を判定する'.turn = turn;
			bind 'LDWの作動を判定する'.hazard = hazard;
			bind 'LDWの作動を判定する'.ldwsw = ldwsw;
			bind '車線逸脱を予測する'.dimension = dimension;
			bind deviation = '車線逸脱を予測する'.deviation;

			item def LaneModel;

			action 'レーンモデルを生成する' {
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
			action 'LDWの作動を判定する' {
				in speed : Real;
				in turn : Items::TurnSignal;
				in hazard : Items::HazardLight;
				in ldwsw : Items::LDWSwState;
				out enable : Boolean;
			}
			action '車線逸脱を予測する' {
				in enable : Boolean;
				in lane_model : LaneModel;
				in dimension : Items::VehicleDemension;
				out deviation : Boolean;
			}
			flow 'レーンモデルを生成する'.lane_model to '車線逸脱を予測する'.lane_model;
			flow 'LDWの作動を判定する'.enable to '車線逸脱を予測する'.enable;
		}
		action '車線逸脱を警告する' {
			dependency '意図しない車線逸脱を検知する' to LDW::Requirements::'車線逸脱防止';
			action '警告灯を点灯する';
			action '警報音を鳴らす';
			first start;
			then fork f1;
				then '警告灯を点灯する';
				then '警報音を鳴らす';
		}
		action '車線逸脱の警告を停止する' {
			dependency '車線逸脱の警告を停止する' to '車線逸脱を警告する';
			action '警告灯を消灯する';
			first start;
			then '警告灯を消灯する';
		}
	}
	package Structure {
		package Ports {
			port def TurnIO {
				out turn : Items::TurnSignal;
			}
			port def HazardIO {
				out hazard : Items::HazardLight;
			}
			port def LDWSwitchIO {
				out ldwsw : Items::LDWSwState;
			}
			port def ImageIO {
				out picture : Items::Picture;
			}
			port def LdwIO {
				out deviation : Boolean;
			}
			port def EcuIO {
				in vangle : Items::ViewAngle;
				in dimension : Items::VehicleDemension;
				in speed : Real;
			}
		}
		part LDW {
			part 'フロントカメラ' {
				port viewPort;
				port img_out : Ports::ImageIO;
				action {
					action trigger accept scene : Items::Scene {
						in :>> receiver = 'フロントカメラ'.viewPort;
					}
					then perform action '外界の映像を取得する';
					then action sendPicture send {
						in payload = Functions::'外界の映像を取得する'.picture;
						in :>> sender = 'フロントカメラ'.img_out;
					}
					flow trigger.scene to Functions::'外界の映像を取得する'.scene;
				}
			}
			part '画像解析装置' {
				port tsig_in : ~Ports::TurnIO;
				port hz_in : ~Ports::HazardIO;
				port ldwsw_in : ~Ports::LDWSwitchIO;
				port img_in : ~Ports::ImageIO;
				port ecu_in : Ports::EcuIO;
				port ldw_out : Ports::LdwIO;
				action {
					action receiveTurn accept info : Ports::TurnIO {
						in :>> receiver = '画像解析装置'.tsig_in;
					}
					then '意図しない車線逸脱を検知する';
					action receiveHazard accept info : Ports::HazardIO {
						in :>> receiver = '画像解析装置'.hz_in;
					}
					then '意図しない車線逸脱を検知する';
					action receiveLdwSw accept info : Ports::LDWSwitchIO {
						in :>> receiver = '画像解析装置'.ldwsw_in;
					}
					then '意図しない車線逸脱を検知する';
					action receivePicture accept info : Ports::ImageIO {
						in :>> receiver = '画像解析装置'.img_in;
					}
					then '意図しない車線逸脱を検知する';
					action receiveEcu accept info : Ports::EcuIO {
						in :>> receiver = '画像解析装置'.ecu_in;
					}
					then '意図しない車線逸脱を検知する';
					perform action '意図しない車線逸脱を検知する';
					then action sendResule send {
						in payload = Functions::'意図しない車線逸脱を検知する'.dimension;
						in :>> sender = '画像解析装置'.ldw_out;
					}
					flow receiveTurn.info.turn to Functions::'意図しない車線逸脱を検知する'.turn;
					flow receiveHazard.info.hazard to Functions::'意図しない車線逸脱を検知する'.hazard;
					flow receiveLdwSw.info.ldwsw to Functions::'意図しない車線逸脱を検知する'.ldwsw;
					flow receivePicture.info.picture to Functions::'意図しない車線逸脱を検知する'.picture;
					bind receiveEcu.info.vangle = Functions::'意図しない車線逸脱を検知する'.vangle;
					bind receiveEcu.info.dimension = Functions::'意図しない車線逸脱を検知する'.dimension;
					bind receiveEcu.info.speed = Functions::'意図しない車線逸脱を検知する'.speed;
				}
			}
			part '方向指示器' {
				attribute ts_stat : Items::TurnSignal;
				port tsig_out : Ports::TurnIO;
				perform action '方向指示器を右折にする' {
					assign ts_stat := Items::TurnSignal::right;
					send ts_stat via tsig_out;
				}
				perform action '方向指示器を左折にする' {
					assign ts_stat := Items::TurnSignal::left;
					send ts_stat via tsig_out;
				}
				perform action '方向指示器をOFFにする' {
					assign ts_stat := Items::TurnSignal::off;
					send ts_stat via tsig_out;
				}
			}
			part '非常点滅灯' {
				attribute hz_stat : Items::HazardLight;
				port hz_out : Ports::HazardIO;
				perform action '非常点滅灯をONにする' {
					assign hz_stat := Items::HazardLight::on;
					send hz_stat via hz_out;
				}
				perform action '非常点滅灯をOFFにする' {
					assign hz_stat := Items::HazardLight::off;
					send hz_stat via hz_out;
				}
			}
			part MFD {
				port ldw_in : ~Ports::LdwIO;
				perform action '車線逸脱を警告する';
				perform action '車線逸脱の警告を停止する';	
			}
			part 'ハンドルスイッチ' {
				attribute ldwsw : Items::LDWSwState;
				port ldwsw_out : Ports::LDWSwitchIO;
				perform action 'LDWをONにする' {
					assign ldwsw := Items::LDWSwState::on;
					send ldwsw via ldwsw_out;
				}
				perform action 'LDWをOFFにする' {
					assign ldwsw := Items::LDWSwState::off;
					send ldwsw via ldwsw_out;
				}
			}
			bind '画像解析装置'.hz_in = '非常点滅灯'.hz_out;
			bind '画像解析装置'.tsig_in = '方向指示器'.tsig_out;
			bind '画像解析装置'.ldwsw_in = 'ハンドルスイッチ'.ldwsw_out;
			bind '画像解析装置'.img_in = 'フロントカメラ'.img_out;
			bind MFD.ldw_in = '画像解析装置'.ldw_out;
		}
	}
}
