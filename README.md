# nexusd_streaming
A collection of scripts that use Nexus-D API by Medtronic to stream brain data from humans implanted with sensing deep brain and cortical electrodes.

The main script is PCS_STREAMING_MAIN.m. Almost all other .m files are helper functions. 

The code needs the Nexus-D API to work (not includede here). Nexus-D is an API that works with the deep brain stimulation system called PC+S. This system has sensing capabilities in addition to brain stimulation. Nexus-D takes streaming data sent from internal brain sensors that are implanted in deep or cortical brain structures. This project takes in that data, visualizes it in real time, and allows the user to switch on/off brain stimulation, and switch between brain stimulation settings.

This code has been used in a deep brain stimulation project still ongoing at Massachussetts General Hospital/Harvard Medical School.

The script creates a GUI for visualizing data streaming and changing stimulation parameters. Here is a screenshot from a previous version. Newer versions have aesthetic improvements and more functionality for stimulation changes but I don't have access to the hardware anymore.

![App GUI](/images/data_streaming_real_data.PNG)
