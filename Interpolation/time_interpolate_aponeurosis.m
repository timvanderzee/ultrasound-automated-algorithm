function[aponeurosis_vector_int] = time_interpolate_aponeurosis(aponeurosis_vector,N)

[m,n] = size(aponeurosis_vector);

aponeurosis_vector_int = nan(size(aponeurosis_vector));

for i = 1:n
    x = 1:m;
    
    % step 1: remove outliers that are more than x SDs away from the mean
    M = mean(aponeurosis_vector(:,i),'omitnan');
    aponeurosis_vector(abs(aponeurosis_vector(:,i)-M) > N*std(aponeurosis_vector(:,i),1,'omitnan'),i) = nan;
    
    % step 2: interpolate over time
    aponeurosis_vector_int(:,i) = interp1(x(isfinite(aponeurosis_vector(:,i))), aponeurosis_vector(isfinite(aponeurosis_vector(:,i)),i), x,'linear','extrap');
end
end