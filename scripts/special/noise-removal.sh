#!/bin/bash

# from https://cubethethird.wordpress.com/2015/07/26/real-time-background-noise-cancellation-of-microphone-input-on-linux/

time=5
workDir='/tmp'
cd $workDir

echo "loading snd_aloop"
sudo modprobe snd_aloop

#get pulse audio devices
devices=`pactl list | grep -E -A2 '(Source|Sink) #' | grep 'Name: ' | grep -v monitor | cut -d" " -f2`
if [ `echo "$devices" | grep -c aloop` -lt 1 ]; then
    echo "No loopback device created. Run 'sudo modprobe snd_aloop' first."
    exit
fi

input=`echo "$devices" | grep input.*pci`
output=`echo "$devices" | grep output.*aloop`

echo "using input  $input"
echo "using output $output"


record()
{
    echo "Recording background noise. Keep quiet for $time seconds."
    sleep 3
    #arecord -f cd noise.wav &
    parecord -d $input noise.wav &
    PID=$!
    sleep $time
    kill $PID
    aplay noise.wav
}


if [ ! -e "noise.prof" ]; then
	#record noise sample
	record
	while true; do
		read -p "Do you wish to re-record the noise sample?" yn
		case $yn in
			[Yy]* ) record;;
			[Nn]* ) break;;
			* ) echo "Please answer yes or no.";;
		esac
	done

	#create noise profile
	sox noise.wav -n noiseprof noise.prof
fi

echo "Sending output to loopback device. Change recording port to &lt;Loopback Analog Stereo Monitor&gt; in PulseAudio to apply. Ctrl+C to terminate."

#filter audio from $input to $output
pacat -r -d $input --latency=1msec | sox -b 16 -e signed -c 2 -r 44100 -t raw - -b 16 -e signed -c 2 -r 44100 -t raw - noisered noise.prof 0.2 | pacat -p -d $output --latency=50msec
#pacat -r -d $input --latency=1msec | pacat -p -d $output --latency=1msec
