cd /mindhive/saxelab2/KMVPA/behavioural/;
subjectIDs = makeIDs('KMVPA',[1:3 5:22 24:29]); 

rest = 10; %seconds  (opening credits)
for subj = 1:length(subjectIDs)
    subjID = subjectIDs{subj}
     
    [~, name] = strtok(subjID,'_');
    [~, name] = strtok(name,'_');
    [IDnum, ~] = strtok(name,'_');
    IDnum = str2num(IDnum);
    

condnames = {'mental','physical','social_sensation','social_relationships'};
conditions = 1:length(condnames);
num_cond = length(conditions);


%times **in TRs** from movie file onset (includes credit:  movie starts at 10s)
sortedonsets = [
1	87
1	121
1	131
1	139
2	8
2	20
2	31	
3	57
3	63
3	74
3	92
3	99
3	108
3	152	
4	27
4	39
4	44
4	51
4	58
                ];

sortedonsets(:,2) = sortedonsets(:,2) + rest/2  ; %%acount for the fact that there was 10s of rest 
  
  
sortedDurations = [
1		4
1		4
1		5
1		9			
2		3
2		5
2		4
3		1
3		3
3		2
3		1
3		3
3		2
3		1
4		3
4		5
4		1
4		3
4		2
                ] ;
                     

ips = 168;
    
for index = 1:num_cond
    spm_inputs(index).name = condnames{index};
    spm_inputs(index).ons = sortedonsets(find(sortedonsets(:,1)==conditions(index)),2);
    spm_inputs(index).dur = sortedDurations(find(sortedDurations(:,1)==conditions(index)),2);
end
    %order: [mental physical pain relationships]
    con_info(1).name = 'mental > physical';
    con_info(1).vals = [1 -1 0 0 ];
    con_info(2).name = 'mental > pain';
    con_info(2).vals = [1 0 -1 0 ];
    con_info(3).name = 'mental > relationships';
    con_info(3).vals = [1 0 0 -1 ];
    
    con_info(4).name = 'pain > physical';
    con_info(4).vals = [0 -1 1 0 ];

    con_info(5).name = 'relationships > physical';
    con_info(5).vals = [0 -1 0 1 ];
    
    
save([subjID '.PIXAR.' num2str(1) '.mat'],'spm_inputs','ips','con_info');
end
sprintf('done!')
