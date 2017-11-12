clear all;
clc;
windowmin = input('lower-bound?');
windowmax = input('upper-bound?');
windowmin = windowmin + 4* windowmin +1
windowmax = windowmax + 4* windowmax +1
%%
A = randi(100,100)
c = A(:,1)
[M, I] = min(c(windowmin:windowmax))
reali = I+windowmin
