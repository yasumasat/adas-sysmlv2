package LDW {
	private import ScalarValues::*;
	//private import ADAS::*;
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
		enum def LDWSwitch {		// LDWスイッチ
			off;
			on;
		}
	}
	package Functions {
		action '外界の映像を取得する' {
			in scene : ADAS::Items::Scene;
			out picture : ADAS::Items::Picture;
		}
		action 'レーンモデルを生成する' {
			doc /*車両に対するレーンを検出する*/
			in picture : ADAS::Items::Picture;
			in vangle : ADAS::Items::ViewAngle;
			out model : ADAS::Items::LaneModel;
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
			in turn : Vehicle::Items::TurnSignal;
			in hazard : Vehicle::Items::HazardLight;
			in ldwsw : Items::LDWSwitch;
			out enable : Boolean;
		}
		action '車線逸脱を予測する' {
			in enable : Boolean;
			in model : ADAS::Items::LaneModel;
			in dimension : Vehicle::Items::VehicleDemension;
			out warn : Boolean;
		}
		action '車線逸脱を警告する' {
			dependency '車線逸脱を警告する' to Requirements::'車線逸脱防止';
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
	package Ports {
		port def TurnIO {
			out turn : Vehicle::Items::TurnSignal;
		}
		port def HazardIO {
			out hazard : Vehicle::Items::HazardLight;
		}
		port def LDWSwitchIO {
			out sw : Items::LDWSwitch;
		}
		port def ImageIO {
			out picture : ADAS::Items::Picture;
		}
		port def LdwIO {
			out warn : Boolean;
		}
		port def EcuIO {
			in vangle : ADAS::Items::ViewAngle;
			in dimension : Vehicle::Items::VehicleDemension;
			in speed : Real;
			in steer : Real;
		}
	}
	part LDW {
		part 'フロントカメラ' {
			port viewPort;
			port img_out : Ports::ImageIO;
			action '画像を撮る' {
				action trigger accept scene : ADAS::Items::Scene via 'フロントカメラ'.viewPort;
				then perform action '外界の映像を取得する';
				then action sendPicture send via 'フロントカメラ'.img_out;
				flow from trigger.scene to Functions::'外界の映像を取得する'.scene;
			}
		}
		part '画像解析装置' {
			port tu_in : ~Ports::TurnIO;
			port hz_in : ~Ports::HazardIO;
			port ldwsw_in : ~Ports::LDWSwitchIO;
			port img_in : ~Ports::ImageIO;
			port ecu_in : Ports::EcuIO;
			port ldw_out : Ports::LdwIO;
			action '意図しない車線逸脱を検知する' {
				action receiveTurn accept info : Ports::TurnIO via tu_in;
				action receiveHazard accept info : Ports::HazardIO via hz_in;
				action receiveLdwSw accept info : Ports::LDWSwitchIO via ldwsw_in;
				action receivePicture accept info : Ports::ImageIO via img_in;
				action receiveEcu accept info : Ports::EcuIO via ecu_in;
				perform Functions::'LDWの作動を判定する';
				perform Functions::'車線逸脱を予測する';
				perform Functions::'レーンモデルを生成する';
				action sendResult send via ldw_out;
				flow from receiveTurn.info.turn to 'LDWの作動を判定する'.turn;
				flow from receiveHazard.info.hazard to 'LDWの作動を判定する'.hazard;
				flow from receiveLdwSw.info.sw to 'LDWの作動を判定する'.ldwsw;
				flow from receivePicture.info.picture to 'レーンモデルを生成する'.picture;
				//flow from receiveEcu.info.vangle to 'レーンモデルを生成する'.vangle;
				//flow from receiveEcu.info.dimension to '車線逸脱を予測する'.dimension;
				//flow from receiveEcu.info.speed to 'LDWの作動を判定する'.speed;
				bind 'レーンモデルを生成する'.vangle = receiveEcu.info.vangle;
				bind '車線逸脱を予測する'.dimension = receiveEcu.info.dimension;
				bind 'LDWの作動を判定する'.speed = receiveEcu.info.speed;
				flow from 'LDWの作動を判定する'.enable to '車線逸脱を予測する'.enable;
				flow from 'レーンモデルを生成する'.model to '車線逸脱を予測する'.model;
			}
		}
		part '方向指示器' {
			attribute turn : Vehicle::Items::TurnSignal;
			port tu_out : Ports::TurnIO;
			perform action '方向指示器を右折にする' {
				assign turn := Vehicle::Items::TurnSignal::right;
				send turn via tu_out;
			}
			perform action '方向指示器を左折にする' {
				assign turn := Vehicle::Items::TurnSignal::left;
				send turn via tu_out;
			}
			perform action '方向指示器をOFFにする' {
				assign turn := Vehicle::Items::TurnSignal::off;
				send turn via tu_out;
			}
		}
		part '非常点滅灯' {
			attribute hazard : Vehicle::Items::HazardLight;
			port hz_out : Ports::HazardIO;
			perform action '非常点滅灯をONにする' {
				assign hazard := Vehicle::Items::HazardLight::on;
				send hazard via hz_out;
			}
			perform action '非常点滅灯をOFFにする' {
				assign hazard := Vehicle::Items::HazardLight::off;
				send hazard via hz_out;
			}
		}
		part MFD {
			port ldw_in : ~Ports::LdwIO;
			perform action '車線逸脱を警告する';
			perform action '車線逸脱の警告を停止する';	
		}
		part 'ハンドルスイッチ' {
			attribute switch : Items::LDWSwitch;
			port ldwsw_out : Ports::LDWSwitchIO;
			perform action 'LDWをONにする' {
				assign switch := Items::LDWSwitch::on;
				send switch via ldwsw_out;
			}
			perform action 'LDWをOFFにする' {
				assign switch := Items::LDWSwitch::off;
				send switch via ldwsw_out;
			}
		}
		port viewPort;
		bind 'フロントカメラ'.viewPort = viewPort;
		bind '画像解析装置'.img_in = 'フロントカメラ'.img_out;
		bind '画像解析装置'.tu_in = '方向指示器'.tu_out;
		bind '画像解析装置'.hz_in = '非常点滅灯'.hz_out;
		bind '画像解析装置'.ldwsw_in = 'ハンドルスイッチ'.ldwsw_out;
		bind MFD.ldw_in = '画像解析装置'.ldw_out;
	}
}
