package io.flutter.plugins;


import java.io.File;
import java.io.IOException;


import io.flutter.embedding.engine.plugins.FlutterPlugin; //setting packge io
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import com.cipherlab.rfidapi.RfidManager;
import com.cipherlab.rfidapi.RfidManagerAPI;
import com.cipherlab.rfid.RFIDMode;
import com.cipherlab.rfid.TriggerSwitchMode;
import com.cipherlab.rfid.DeviceEvent;
import com.cipherlab.rfid.DeviceInfo;
import com.cipherlab.rfid.WorkMode;
import com.cipherlab.rfid.InventoryType;
import com.cipherlab.rfid.EPCData;
import com.cipherlab.rfid.RFIDMemoryBank;
import com.cipherlab.rfid.ClResult;
import com.cipherlab.rfid.ScanMode;
import com.cipherlab.rfid.RfidEpcFilter;
import com.cipherlab.rfid.GeneralString;
import com.cipherlab.rfid.FWUpdateErrorCode;
import com.cipherlab.rfid.DeviceVoltageInfo;



import com.google.gson.Gson;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.InputDevice;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import android.widget.CheckBox;
import java.util.HashMap;
import java.util.Map;

public class MyFlutterPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private RfidManager mRfidManager;
    private RFIDMode rfidMode;
    private TriggerSwitchMode trgMode;
    String TAG = "RFID_sample";
	TextView tv1 = null;
    Button b1 = null;
    CheckBox mCheckBox_SwitchStatus = null;
	CheckBox mCheckBox_ScanMode = null;
	private ScanMode selMode;
 
    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(),"com.example/customChannel");
        channel.setMethodCallHandler(this);
        IntentFilter filter = new IntentFilter();
        filter.addAction(GeneralString.Intent_RFIDSERVICE_CONNECTED);
		filter.addAction(GeneralString.Intent_RFIDSERVICE_TAG_DATA);
		filter.addAction(GeneralString.Intent_RFIDSERVICE_EVENT);
		filter.addAction(GeneralString.Intent_FWUpdate_ErrorMessage);
		filter.addAction(GeneralString.Intent_FWUpdate_Percent);
		filter.addAction(GeneralString.Intent_FWUpdate_Finish);
		filter.addAction(GeneralString.Intent_GUN_Attached);
		filter.addAction(GeneralString.Intent_GUN_Unattached);
		filter.addAction(GeneralString.Intent_GUN_Power);
        mRfidManager = RfidManager.InitInstance(binding.getApplicationContext());
        binding.getApplicationContext().registerReceiver(myDataReceiver, filter);
        tv1 = new TextView(binding.getApplicationContext());
    }
    private final BroadcastReceiver myDataReceiver = new BroadcastReceiver() 
	{
		@Override
		public void onReceive(Context context, Intent intent) {
          
			
			try{
					
		
                 if(intent.getAction().equals(GeneralString.Intent_RFIDSERVICE_TAG_DATA))
			{
				/* 
				 * type : 0=Normal scan (Press Trigger Key to receive the data) ; 1=Inventory EPC ; 2=Inventory ECP TID ; 3=Reader tag ; 5=Write tag ; 6=Lock tag ; 7=Kill tag ; 8=Authenticate tag ; 9=Untraceable tag
				 * response : 0=RESPONSE_OPERATION_SUCCESS ; 1=RESPONSE_OPERATION_FINISH ; 2=RESPONSE_OPERATION_TIMEOUT_FAIL ; 6=RESPONSE_PASSWORD_FAIL ; 7=RESPONSE_OPERATION_FAIL ;251=DEVICE_BUSY
				 * */
				int type = intent.getIntExtra(GeneralString.EXTRA_DATA_TYPE, -1);
				int response = intent.getIntExtra(GeneralString.EXTRA_RESPONSE, -1);
				double data_rssi = intent.getDoubleExtra(GeneralString.EXTRA_DATA_RSSI, 0);
				
				String PC = intent.getStringExtra(GeneralString.EXTRA_PC);
				String EPC = intent.getStringExtra(GeneralString.EXTRA_EPC);
				String TID = intent.getStringExtra(GeneralString.EXTRA_TID);
				String ReadData = intent.getStringExtra(GeneralString.EXTRA_ReadData);
				int EPC_length = intent.getIntExtra(GeneralString.EXTRA_EPC_LENGTH, 0);
				int TID_length = intent.getIntExtra(GeneralString.EXTRA_TID_LENGTH, 0);
				int ReadData_length = intent.getIntExtra(GeneralString.EXTRA_ReadData_LENGTH, 0);
				
				String Data = "response = " + response + " , EPC = " + EPC + "\r TID = " + TID;
				tv1.setText(Data);
				//e1.setText(EPC);
				// Log.w(TAG, "++++ [Intent_RFIDSERVICE_TAG_DATA] ++++");	
				// Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] EPC=" + EPC );
                sendEPCToFlutter(EPC);
			
			// If type=8 ; Authenticate response data in ReadData
				if(type==GeneralString.TYPE_AUTHENTICATE_TAG && response==GeneralString.RESPONSE_OPERATION_SUCCESS)
				{
					Log.i(TAG, "Authenticate response data=" + ReadData );
				}
			} else if(intent.getAction().equals(GeneralString.Intent_GUN_Power))
			{
				Log.d(TAG,  "Intent_GUN_Power" );
				boolean AC = intent.getBooleanExtra(GeneralString.Data_GUN_ACPower, false);
				boolean Connect = intent.getBooleanExtra(GeneralString.Data_GUN_Connect, false);
			}
            }catch (Exception e) {
                Log.e("BroadcastReceiver", "Error in onReceive", e);
            }
		}
	};

       private void sendEPCToFlutter(String epc) {
       
        channel.invokeMethod("onTagScanned", epc);
    }
	private void sendConnection(boolean status) {
       
        channel.invokeMethod("Connection", status);
    }


   @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Gson gson = new Gson();
        switch (call.method) {
            case "getServiceVersion":
                String version = mRfidManager.GetServiceVersion();
                result.success(version);
                break;
			case "TrgMode":
			mRfidManager.SoftScanTrigger(Boolean.parseBoolean(call.argument("statusTrg").toString()));
			result.success("Scanning");
			break;
			case "Connection":
				result.success(mRfidManager.GetConnectionStatus());
				break;
			case "GetScanMode":
				result.success(mRfidManager.GetScanMode().toString());
				break;
				case "SetScanMode":
				
				if(call.argument("mode").toString().equalsIgnoreCase("alternate")){
					int re = mRfidManager.SetScanMode(selMode.Alternate);
					if(re != ClResult.S_OK.ordinal()){
						result.success(mRfidManager.GetLastError());
					}else{
						result.success("Set Mode Alternate Success");
					}

				}else if(call.argument("mode").toString().equalsIgnoreCase("single")){
					int re = mRfidManager.SetScanMode(selMode.Single);
					if(re != ClResult.S_OK.ordinal()){
						result.success(mRfidManager.GetLastError());
					}else{
						result.success("Set Mode Once Success");
					}
					
				}else if(call.argument("mode").toString().equalsIgnoreCase("continuous")){
					int re = mRfidManager.SetScanMode(selMode.Continuous);
					if(re != ClResult.S_OK.ordinal()){
						result.success(mRfidManager.GetLastError());
					}else{
						result.success("Set Mode Continuous Success");
					}
				}else{
					result.success("Error");
				}
				
				break;
            default:
                result.notImplemented();
                break;
        }
    }

    
 
  @Override
public void onDetachedFromEngine(FlutterPluginBinding binding) {
    if (mRfidManager != null) {
        mRfidManager.Release();
        mRfidManager = null;
    }
    Log.d(TAG,  "Intent_GUN_Power" );
    channel.setMethodCallHandler(null);
}
}
