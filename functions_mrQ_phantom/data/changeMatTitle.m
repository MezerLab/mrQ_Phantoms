function changeMatTitle(title)

% changes the Matlab window title.
% Written by Racheli.

 jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
 jDesktop.getMainFrame.setTitle(title);
 
 % that's it!


end