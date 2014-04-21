function y = pitchshift(Y,f)

% KEYS THAT ARE CONSIDERED FOR NOW
% V is the vector containing the keys

%Y is the loudness (not completely propertional)
% f is the frequency (sample length 12) 
%  where x is the number you want to shift 
%  fprintf('Maximum occurs at %d Hz.\n',f(I));
 [~,I] = max(abs(Y));
x= 0;
V  = [ 440.000000000000000   466.163761518089916 493.883301256124111   523.251130601197269 ...
      554.365261953744192   587.329535834815120    622.253967444161821   659.255113825739859 ...
      698.456462866007768   739.988845423268797 783.990871963498588   830.609395159890277 ...
      880.000000000000000   932.327523036179832 987.766602512248223  1046.502261202394538 ...
      1108.730523907488384  1174.659071669630241 1244.507934888323642  1318.510227651479718 ...
      1396.912925732015537  1479.977690846537595 1567.981743926997176  1661.218790319780554 ...
      1760.000000000000000  1864.655046072359665];

  v = 1:1:25;
for i = 1:25%:length(v) % looping through keys where the subsequent keys have...
            % same gap in frequency \
   if V(i) < f(I) && f(I)< V(i+1)
       z= v(i);
   if abs(f(I)- V(z))< (V(z+1) - V(z))/2 % for instance 450
       x = -1*((f(I)) - V(z));
    elseif  (V(z+1) - V(z))/2 < abs(f(I)- V(z)) % for instance 490
       x = -1*((f(I))- V(z+1));
   end   
   end
 
 y=  circshift(Y, [round(0.7447 * x)  0]);
end
