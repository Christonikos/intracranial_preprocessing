function stamp=find_event(data,th,id_type,th_type,reject)
%  id_type 1: find the first crossing point.
%          2: if a succesive series of timestamps are found, get the peak.
%          3: if a succesive series of timestamps are found, get the
%          central point.
%   Written by Su Liu
if nargin<5 || isempty(reject)
    if th_type==0
        reject=9;
    else
        reject=5;
    end
end

% if ~isempty(index(data(index)>reject*th))
%      index(data(index)>reject*th)=[];
% end
 

% index=find(data>th);
% index_m=find(data<-th);

index=sort([find(data>th);find(data<-th)]); % C: get samples that exceed the abs value of the threshold 
% which was set in the previous function to be 5 times the median of the temporal variance. 
r_ind=[find(data(index)>reject*th);find(data(index)<(-reject*th))]; % C : find the sample points that exceed the reject*thr, that is
% 5*5thr = 25 times the median of the temporal variance.
if ~isempty(r_ind)
     index(r_ind)=[];
end

 
li=length(index);
q=1;
count=0;
if li==0 || li==1
    get_idx=[];
else   
    F=find(diff(index)<=100); % Chris : I guess in samples. find sample points that don't pass the 100mv barrier of the events that exceed 5*the median variance
    if ~isempty(F)
        if length(F)==1
            group{1}=index(F:F+1);
        else
            F(:,2)=F(:,1)+1; % C :get the adjacent samples points 
            for i=1:length(F)-1  % C: loop through those sample points  
                if F(i,2)~=F(i+1,1) % C : why is that?
                    group{q} = index(F(i-count,1):F(i,2)); 
                    index(F(i-count,1):F(i,2))=0;
                    count=0;
                    q=q+1;
                else
                    count=count+1;
                    if i==length(F)-1
                        group{q}=index(F(i+1-count,1):F(end));
                        index(F(i+1-count,1):F(end))=0;
                    else
                        continue;
                    end
                end
            end
        end
         atf=zeros(length(group),1); % C : the length of the group is the #events that exceeded the threshold
        if th_type==1
            for i=1:length(group) 
                % C : if you have too big or too small events, set them to
                % 1
                if length(group{i})>100 %set the criteria 
                    atf(i)=1;
                elseif length(group{i})<=2%old:10                   
                    atf(i)=1;
                end
            end
        else
            for i=1:length(group)
                if length(group{i})>60
                %if length(group{i})>30;
                    atf(i)=1;
                end
            end
         end
        group(logical(atf))=[];  %C: keep only the groups that are not too small or too big      
        get_idx=zeros(length(group),1); % C : initialize again with the non rejected events
        for i=1:length(group) % C: loop through the groups
            switch id_type
                case 1
                    get_idx(i,1)=group{i}(1);
                case 2
                    % C : get the peaks of the groups
                    get_idx(i,1)=group{i}(data(group{i})==max(data(group{i})));
                case 3
                    get_idx(i,1)=round(median(group{i}));
                case 4
                    if length(group{i})>=8
                        n=1:length(group{i})-1;
                        a=find(abs(gradient(diff(group{i}),n))<2);
                        if any(diff(a)==1)
                            get_idx(i,1)=group{i}(floor(median(a(find(diff(a)==1)+1)+1)));
                        else
                            get_idx(i,1)=group{i}(round(median([a(1);a+1])));
                        end
                    else
                        get_idx(i,1)=group{i}(data(group{i})==max(data(group{i})));
                    end
            end
        end
        
    end
end
index(index==0)=[];
if th_type==0
    if exist('get_idx','var')    
        stamp=sort([get_idx;index]);
    else
        stamp=index;
    end
else
    if ~exist('get_idx','var') 
        get_idx=[];
    end
stamp=get_idx;
end
discard= data(stamp)>reject*th;
stamp(discard)=[]; % C : 5th< peaks <25th?

end
