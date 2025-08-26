package com.drnull.blindify;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import java.io.DataOutputStream;
import java.io.IOException;

public class MainActivity extends Activity {

    
    private static final String TAG = "BlindifyApp";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button disableButton = findViewById(R.id.disable_camera_button);
        Button enableButton = findViewById(R.id.enable_camera_button);

        disableButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                
                final String[] commands = {
                        "stop cameraserver",
                        "chmod 000 /dev/video*"
                };
                executeRootCommands(commands, "Camera Disabled At The Root Level.");
            }
        });

        enableButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                
                final String[] commands = {
                        "chmod 660 /dev/video*",
                        "start cameraserver"
                };
                executeRootCommands(commands, "Camera Enabled At The Root Level.");
            }
        });
    }

   
    private void executeRootCommands(final String[] commands, final String toastMessage) {
        // Creating new thread to not block the ui
        new Thread(new Runnable() {
            @Override
            public void run() {
                boolean success = false;
                try {
                    
                    Process suProcess = Runtime.getRuntime().exec("su");

                 
                    DataOutputStream os = new DataOutputStream(suProcess.getOutputStream());

                    
                    for (String command : commands) {
                        os.writeBytes(command + "\n");
                        os.flush();
                    }

                    
                    os.writeBytes("exit\n");
                    os.flush();

                    
                    int exitValue = suProcess.waitFor();
                    if (exitValue == 0) {
                        
                        success = true;
                    } else {
                        
                        Log.e(TAG, "Root command execution failed with exit code: " + exitValue);
                    }

                    
                    os.close();

                } catch (IOException | InterruptedException e) {
                    // This can happen if the device is not rooted or permission is denied
                    Log.e(TAG, "Error executing root commands: " + e.getMessage());
                    e.printStackTrace();
                }

                // To show a Toast, we must get back on the main UI thread
                final boolean finalSuccess = success;
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (finalSuccess) {
                            Toast.makeText(MainActivity.this, toastMessage, Toast.LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(MainActivity.this, "Failed to execute root commands.", Toast.LENGTH_LONG).show();
                        }
                    }
                });
            }
        }).start(); 
    }
}