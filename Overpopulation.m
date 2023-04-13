%Reads the data file into MATLAB
t = table2struct(readtable('aac_intakes_outcomes.csv'));
tClean = t([1:10000]);           %selecting the first 10,000 data points from the randomly sorted data set
%Data Scrubbing: removing fields that are irrelevant/redundant
tClean = rmfield(tClean, "color");
tClean = rmfield(tClean, "outcome_monthyear");
tClean = rmfield(tClean, "outcome_weekday");
tClean = rmfield(tClean, "outcome_hour");
tClean = rmfield(tClean, "intake_monthyear");
tClean = rmfield(tClean, "intake_hour");
tClean = rmfield(tClean, "intake_weekday");
tClean = rmfield(tClean, "count");
tClean = rmfield(tClean, "age_upon_outcome__days_");
tClean = rmfield(tClean, "age_upon_intake__days_");
tClean = rmfield(tClean, "age_upon_outcome_age_group");
tClean = rmfield(tClean, "age_upon_intake_age_group");
tClean = rmfield(tClean, "dob_monthyear");
tClean = rmfield(tClean, "date_of_birth");
tClean = rmfield(tClean, "time_in_shelter");
tClean = rmfield(tClean, "outcome_subtype");
tClean = rmfield(tClean, "animal_id_intake");
tClean = rmfield(tClean, "animal_id_outcome");
tClean = rmfield(tClean, "age_upon_outcome");
tClean = rmfield(tClean, "outcome_datetime");
tClean = rmfield(tClean, "outcome_month");
tClean = rmfield(tClean, "intake_datetime");
tClean = rmfield(tClean, "intake_month");
tClean = rmfield(tClean, "dob_year");
tClean = rmfield(tClean, "dob_month");
tClean = rmfield(tClean, "age_upon_intake");
tClean = rmfield(tClean, "found_location");
tClean = rmfield(tClean, "sex_upon_intake");
tClean = rmfield(tClean, "outcome_year");
tClean = rmfield(tClean, "outcome_number");
tClean = rmfield(tClean, "intake_condition");
tClean = rmfield(tClean, "intake_type");
tClean = rmfield(tClean, "intake_year");
tClean = rmfield(tClean, "intake_number");
tClean = rmfield(tClean, "age_upon_intake__years_");
%%
%Removes non-dog animals from the data set (i.e. Cats & Other)
[r c] = size(tClean);
i = 1;
while (i <= r)
   if isequal(tClean(i).animal_type, 'Cat') || isequal(tClean(i).animal_type, 'Other')
       tClean(i) = [];
       i = i-1;
   end
   i = i + 1;
   [r c] = size(tClean);
end
%%
%Puts age and respective time in shelter in two separate vectors to be plotted
[r c] = size(tClean);
agevec = zeros(1,r);
shelttimevec = zeros(1,r);
for i = 1:r
   agevec(1,i) = [tClean(i).age_upon_outcome__years_];
   shelttimevec(1,i) = [tClean(i).time_in_shelter_days];
end
%Plots the two vectors created above
figure(1)
scatter(agevec,shelttimevec, 'k')
xlabel('Age')
ylabel('Time in Shelter (days)')
title('Time in Shelter (days) vs Age')
%%
%Calculates the average shelter time for each age
[r c] = size(tClean);
ageshelttimes = zeros(1,20);
for i = 1:20
   count = 0;
   timeTotal = 0;
   for j = 1:r
       if (round(tClean(j).age_upon_outcome__years_) == i)
         count = count + 1;
         timeTotal = timeTotal + tClean(j).time_in_shelter_days;
       end
   end
   ageshelttimes(i) =  [timeTotal/count];
end
%Plots each age as an integer against their respective average shelter stay times
ages = [1:20];
figure(2)
scatter(ages, ageshelttimes, 'k*')
xlabel('Age')
ylabel('Average Shelter Time per Age')
title('Average Shelter Time per Age vs Age')
%Calculates the correlation coefficient between age and average shelter stay time
cc = corrcoef(ages, ageshelttimes);
cc(1,2);
%%
%Counts how many of each outcome occurs based on gender
malecount = 0;
femalecount = 0;
madoptioncount = 0;
meuthcount = 0;
mreturncount = 0;
mdeathcount = 0;
mtransfercount = 0;
fadoptioncount = 0;
feuthcount = 0;
freturncount = 0;
fdeathcount = 0;
ftransfercount = 0;
for i = 1:r
   gend = tClean(i).sex_upon_outcome;
   outcome = tClean(i).outcome_type;
   if isequal(gend([end-3:end]),'Male')
       malecount = malecount + 1;
       if isequal(outcome, 'Adoption')
           madoptioncount = madoptioncount + 1;
       elseif isequal(outcome, 'Euthanasia')
           meuthcount = meuthcount + 1;
       elseif isequal(outcome, 'Return to Owner')
           mreturncount = mreturncount + 1;
       elseif isequal(outcome, 'Died')
           mdeathcount = mdeathcount + 1;
       elseif isequal(outcome, 'Transfer')
           mtransfercount = mtransfercount + 1;
       end
       mcounts = [madoptioncount meuthcount mreturncount mdeathcount mtransfercount];
       mcounts = mcounts/malecount;
   else
       femalecount = femalecount + 1;
       if isequal(outcome, 'Adoption')
           fadoptioncount = fadoptioncount + 1;
       elseif isequal(outcome, 'Euthanasia')
           feuthcount = feuthcount + 1;
       elseif isequal(outcome, 'Return to Owner')
           freturncount = freturncount + 1;
       elseif isequal(outcome, 'Died')
           fdeathcount = fdeathcount + 1;
       elseif isequal(outcome, 'Transfer') 
           ftransfercount = ftransfercount + 1;
       end
       fcounts = [fadoptioncount feuthcount freturncount fdeathcount ftransfercount];
       fcounts = fcounts/femalecount;
   end
end
%Plots the male vs female outcome counts on two pie charts
figure(3)
labels = {'Adoption','Euthanasia','Return to Owner','Died','Transfer'};
t = tiledlayout(1,2,'TileSpacing','compact');
ax1 = nexttile;
pie(ax1, mcounts)
title('Male Outcomes')
ax2 = nexttile;
pie(ax2, fcounts)
title('Female Outcomes')
lgd = legend(labels);
lgd.Layout.Tile = 'east';
%%

%Compares length of stay to respective outcomes
[r c] = size(tClean);
count = 0;
lessThanWeek = [];
lessThanMonth = [];
lessThanYear = [];
lessThan2Years = [];
moreThan2Years = [];
  for j = 1:r
      if tClean(j).time_in_shelter_days <= 7
        lessThanWeek = [lessThanWeek tClean(j)];
      elseif 7 < tClean(j).time_in_shelter_days && tClean(j).time_in_shelter_days <=30
        lessThanMonth = [lessThanMonth tClean(j)];
      elseif 30 < tClean(j).time_in_shelter_days && tClean(j).time_in_shelter_days <= 365
        lessThanYear = [lessThanYear tClean(j)];
      elseif 365 < tClean(j).time_in_shelter_days && tClean(j).time_in_shelter_days <= 730
        lessThan2Years = [lessThan2Years tClean(j)];
      else
        moreThan2Years = [moreThan2Years tClean(j)];
      end
  end
 [rweek cweek] = size(lessThanWeek);
  ret2own = 0;
  trans = 0;
  adopt = 0;
  euth = 0;
  for i = 1:cweek
      if isequal(lessThanWeek(i).outcome_type, 'Return to Owner')
          ret2own = ret2own + 1;
      elseif isequal(lessThanWeek(i).outcome_type, 'Transfer')
          trans = trans +1;
      elseif isequal(lessThanWeek(i).outcome_type, 'Adoption')
          adopt = adopt +1;
      elseif isequal(lessThanWeek(i).outcome_type, 'Euthanasia')
          euth = euth +1;
      end
  end
 RTAEweek = [ret2own/cweek trans/cweek adopt/cweek euth/cweek];
 
 [rmonth cmonth] = size(lessThanMonth);
  ret2own = 0;
  trans = 0;
  adopt = 0;
  euth = 0;
  for i = 1:cmonth
      if isequal(lessThanMonth(i).outcome_type, 'Return to Owner')
          ret2own = ret2own + 1;
      elseif isequal(lessThanMonth(i).outcome_type, 'Transfer')
          trans = trans +1;
      elseif isequal(lessThanMonth(i).outcome_type, 'Adoption')
          adopt = adopt +1;
      elseif isequal(lessThanMonth(i).outcome_type, 'Euthanasia')
          euth = euth +1;
      end
  end
 RTAEmonth = [ret2own/cmonth trans/cmonth adopt/cmonth euth/cmonth];
 
[ryear cyear] = size(lessThanYear);
  ret2own = 0;
  trans = 0;
  adopt = 0;
  euth = 0;
  for i = 1:cyear
      if isequal(lessThanYear(i).outcome_type, 'Return to Owner')
          ret2own = ret2own + 1;
      elseif isequal(lessThanYear(i).outcome_type, 'Transfer')
          trans = trans +1;
      elseif isequal(lessThanYear(i).outcome_type, 'Adoption')
          adopt = adopt +1;
      elseif isequal(lessThanYear(i).outcome_type, 'Euthanasia')
          euth = euth +1;
      end
  end
 RTAEyear = [ret2own/cyear trans/cyear adopt/cyear euth/cyear];
  [r2year c2year] = size(lessThan2Years);
  ret2own = 0;
  trans = 0;
  adopt = 0;
  euth = 0;
  for i = 1:c2year
      if isequal(lessThan2Years(i).outcome_type, 'Return to Owner')
          ret2own = ret2own + 1;
      elseif isequal(lessThan2Years(i).outcome_type, 'Transfer')
          trans = trans +1;
      elseif isequal(lessThan2Years(i).outcome_type, 'Adoption')
          adopt = adopt +1;
      elseif isequal(lessThan2Years(i).outcome_type, 'Euthanasia')
          euth = euth +1;
      end
  end
 RTAE2years = [ret2own/c2year trans/c2year adopt/c2year euth/c2year];
  [rm2year cm2year] = size(moreThan2Years);
  ret2own = 0;
  trans = 0;
  adopt = 0;
  euth = 0;
  for i = 1:cm2year
      if isequal(moreThan2Years(i).outcome_type, 'Return to Owner')
          ret2own = ret2own + 1;
      elseif isequal(moreThan2Years(i).outcome_type, 'Transfer')
          trans = trans +1;
      elseif isequal(moreThan2Years(i).outcome_type, 'Adoption')
          adopt = adopt +1;
      elseif isequal(moreThan2Years(i).outcome_type, 'Euthanasia')
          euth = euth +1;
      end
  end
 RTAEmore = [ret2own/cm2year trans/cm2year adopt/cm2year euth/cm2year];
 
figure('Name','Dogs in shelter for certain amounts of time: ');
labels = {'Returned to owner','Transfer','Adoption', 'Euthanasia'};
t = tiledlayout('flow');
nexttile;
pie(RTAEweek)
title('Less Than a Week')
nexttile;
pie(RTAEmonth)
title('Less Than a Month')
nexttile;
pie(RTAEyear)
title('Less Than a Year')
nexttile;
pie(RTAE2years)
title('Less Than Two Years')
nexttile;
pie(RTAEmore)
title('More Than Two Years')
lgd = legend(labels);
lgd.Layout.Tile = 'east';
%%
%Identifies the most recurring breed in the shelter using categoricals
breeds = categorical({tClean(:).breed});
sort(countcats(breeds));
figure(5)
breednums = sort([1062 679 582 283 172 129 113 107 96 92]);
breednames = categorical({'Boxer Mix','Border Collie Mix', 'Pit Bull', 'Miniature Poodle Mix', 'Daschund Mix',...
   'Australian Cattle Mix','German Shepherd Mix','Labrador Retriever Mix','Chihuahua Shorthair Mix','Pit Bull Mix'});
bar(reordercats(breednames, {'Boxer Mix','Border Collie Mix', 'Pit Bull', 'Miniature Poodle Mix', 'Dashchund Mix',...
   'Australian Cattle Mix','German Shepherd Mix','Labrador Retriever Mix','Chihuahua Shorthair Mix','Pit Bull Mix'}), breednums)
xlabel('Breed')
ylabel('Number of Occurrences in Shelter')
title('Number of Occurrences in Shelter vs Breed')
%%
%Section included to display rows of some of the dataset as an example
head = head(struct2table(tClean))
tail = tail(struct2table(tClean))
