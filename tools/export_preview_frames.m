function export_preview_frames()
%EXPORT_PREVIEW_FRAMES Sample the committed MP4 for the README GIF.
root=setup_glider(); folder=fullfile(root,'tmp','preview_frames');
if ~exist(folder,'dir'), mkdir(folder); end
reader=VideoReader(fullfile(root,'results','glider_demo.mp4'));
times=linspace(0,max(0,reader.Duration-1/reader.FrameRate),41);
for i=1:numel(times)
    reader.CurrentTime=times(i);
    imwrite(readFrame(reader),fullfile(folder,sprintf('frame_%03d.png',i)));
end
end
