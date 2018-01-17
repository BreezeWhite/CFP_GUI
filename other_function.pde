

int pos2key(int x){
  int key_;
  
  float x_ = x - init_width + w_size_x*1.5;
  key_ = floor(x_/w_size_x*2);
  
  if(key_ < 3) return key_;
  key_ -= 1;
  
  int octave = int((key_-4)/(12+2));
  int offset = (key_-4) % (12+2);
  
  for(int i=0; i<octave; i+=1) key_ -= 2;
  if(offset > 3) key_ -= 1;
  if(offset > 11) key_ -= 1;
  
  return lligalizeKey(key_);
}

int key2pos_x(int key_){
  key_ = lligalizeKey(key_);
  
  if(key_ < 3)
    return int(init_width + (key_-2)*w_size_x/2);
    
  int octave = int((key_-3)/12) + 1;
  int pos = (octave-1) * (12 + 2);
  int offset = (key_-3) % 12 + 1;
  offset = offset>5 ? offset+1 : offset;
  
  return ceil(init_width + (pos+offset+1)*w_size_x/2);
}

int key2pos_y(int key_){
  key_ = lligalizeKey(key_);
  
  if(isBlack(key_)) return int(init_height-(w_size_y-b_size_y)/2);
  return int(init_height);
}

boolean isBlack(int key_){
  lligalizeKey(key_);
  
  if(key_ < 3) return key_==1;
  
  key_ -= 3;
  final int[] black = {1, 3, 6, 8, 10};
  int offset = key_ % 12;
  for(int i=0; i<black.length; i+=1){
    if(offset == black[i]) return true;
  }
  
  return false;
}

int lligalizeKey(int key_){
  if(key_ < 0) return 0;
  if(key_ > 87) return 87;
  return key_;
}