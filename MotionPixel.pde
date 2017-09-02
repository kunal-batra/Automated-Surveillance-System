import processing.video.*; //add video library
import processing.sound.*; //add audio library

SoundFile file;

Capture video;

PImage prevFrame; // to store previous frame

// How different must a pixel be to be a "motion" pixel
float threshold = 65;

int alarm=0, sec=0;

void setup() {
  size(640, 480);

  //to print image sizes supported by the cam uncomment next line
  //printArray(Capture.list());

  //start the capturing from webcam 
  video = new Capture(this, width, height, 30);
  video.start();

  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);

  //alarm sound file
  file = new SoundFile(this, "Osmium.ogg");
}

void captureEvent(Capture video) {

  // Save previous frame for motion detection!!
  // Before we read the new frame, we always save the previous frame for comparison!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();  // Read image from the camera
  video.read();
}

void draw() {

  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {

      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      color current = video.pixels[loc];      // Step 2, what is the current color
      color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous);
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff < threshold) { 

        pixels[loc] = color(0);
      } else {

        pixels[loc] = color(255);
      }

      //saving screenshot with the timestamp
      if (diff > 210) {
        //calculate the timestamp
        String time = hour()+"."+minute()+"."+second();

        // take screenshot after every 3 seconds to limit the lag in processing and saving the image
        if (sec-second()>2 || second()-sec>2 || sec==0) {
          prevFrame.save("motionCapture/"+time+".png"); // name the image with the timestamp and save it
          //print(time);
          sec=second();
        }
        alarm++; 
        //first increment will be when the sketch starts, and second when it detects motion
        //we don't want to initiate play everytime motion is detected, only the first time and make it play in loop to reduce overload
        if (alarm==2) {
          file.loop();
        }
      }
    }
  }

  updatePixels();

  //reference stream in top left
  image(video, 0, 0, width/4, height/4);
}