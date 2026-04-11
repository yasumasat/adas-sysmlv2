package LDP {
	private import ScalarValues::*;
	package Items {
		item def VehicleVolume {
			attribute steer : Real;
			attribute speed : Real;
		}
	}
	package Functions {
		action '車両操作量を算出する' {
			in enable : Boolean;
			in model : ADAS::Items::LaneModel;
			in dimension : Vehicle::Items::VehicleDemension;
			in speed : Real;
			in steer : Real;
			out target : Items::VehicleVolume;
		}
		action 'ステアリング角を設定する' {
			in angle : Real;
		}
		action '目標車速を設定する' {
			in speed : Real;
		}
	}
	package Ports {
		port def ControlIO {
			out volume : Items::VehicleVolume;
		}
		port def SteerIO {
			out angle : Real;
		}
		port def SpeedIO {
			out speed : Real;
		}
	}
	part LDP :> LDW::LDW {
		part 'LDP画像解析装置' :> LDW::LDW.'画像解析装置' {
			port vol_out : Ports::ControlIO;
			port steer_out : Ports::SteerIO;
			port spd_out : Ports::SpeedIO;
			action '意図しない車線逸脱を防止する' :> LDW::LDW.'画像解析装置'.'意図しない車線逸脱を検知する' {
				perform Functions::'車両操作量を算出する';
				action sendControl send via vol_out;
				flow from LDW::Functions::'LDWの作動を判定する'.enable to '車両操作量を算出する'.enable;
				flow from LDW::Functions::'レーンモデルを生成する'.model to '車両操作量を算出する'.model;
				//flow from receiveEcu.info.dimension to '車両操作量を算出する'.dimension;
				//flow from receiveEcu.info.speed to '車両操作量を算出する'.speed;
				//flow from receiveEcu.info.steer to '車両操作量を算出する'.steer;
				bind '車両操作量を算出する'.dimension = receiveEcu.info.dimension;
				bind '車両操作量を算出する'.speed = receiveEcu.info.speed;
				bind '車両操作量を算出する'.steer = receiveEcu.info.steer;
				flow from '車両操作量を算出する'.target to sendControl.payload; 
			}
		}
		part 'パワーステアリング' {
			port steer_in : ~Ports::SteerIO;
			perform Functions::'ステアリング角を設定する';
			bind 'ステアリング角を設定する'.angle = steer_in.angle;
		}
		part '車速コントローラ' {
			port spd_in : ~Ports::SpeedIO;
			perform Functions::'目標車速を設定する';
			bind '目標車速を設定する'.speed = spd_in.speed;
		}
		bind 'パワーステアリング'.steer_in = 'LDP画像解析装置'.steer_out;
		bind '車速コントローラ'.spd_in = 'LDP画像解析装置'.spd_out;
	}
}
