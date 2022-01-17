function[aponeurosis_vector_int] = time_interpolate_aponeurosis(aponeurosis_vector, B)

aponeurosis_vector

[m,n] = size(aponeurosis_vector);

aponeurosis_vector_int = nan(size(aponeurosis_vector));

for i = 1:n
    x = 1:m;
    
    aponeurosis_vector_int(:,i) = interp1(x(isfinite(aponeurosis_vector(:,i))), aponeurosis_vector(isfinite(aponeurosis_vector(:,i)),i), x,'linear','extrap');
end
end