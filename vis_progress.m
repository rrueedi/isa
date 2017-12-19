function cnt = vis_progress(cnt_in,small_step,big_step,str_leadin)
if nargin < 4;str_leadin = '';end
if nargin < 3;big_step = 50;end
if nargin < 2;small_step = 5;end
cnt = cnt_in+1;
if mod(cnt,big_step) == 0;
    fprintf([':\n' str_leadin]);
elseif mod(cnt,small_step) == 0;
    fprintf(':');
elseif cnt == 1;
    fprintf([str_leadin '.']);
else 
    fprintf('.');
end