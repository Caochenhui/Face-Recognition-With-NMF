function rc = FNMF( V, class_V, m_img, n_img, alpha, beta, Train_num, r, maxiter, T, class_T, Test_num, T_orignal)
%V-----------------ѵ�����ݼ���[m*n, Train_num*15]
%class_V-----------ѵ��������Ӧ�ķ���
%m_img-------------V��ͼ���ά��
%n_img-------------V��������
%r-----------------V����
%Train_num---------ѵ��������
%maxiter-----------����������
%T-----------------�������ݼ���[m*n, Test_num*15]
%class_T-----------����������Ӧ�ķ���
%Test_num----------ѵ��������

%% ѵ��
C = 40;
ni = 8;
constH = 2 / (C * ni) - 4 / (ni * ni * (C - 1));
J = zeros(maxiter, 1);
V = V/max(V(:));
V(V == 0) = 2;                                                             %�滻0ֵ��������ۺ�����ɢ
V(V == 2) = min(min(V)) * 0.01;
T = T/max(T(:));
T(T == 0) = 2;                                                             %�滻0ֵ��������ۺ�����ɢ
T(T == 2) = min(min(T)) * 0.01;
W = abs(randn(m_img * n_img, r));                                          %�Ǹ���ʼ��
H = abs(randn(r, Train_num * 40));
for i = 1 : r                                                              %��W���и���ģΪ1��Լ��
    W(:, i) = W(:, i) / norm(W(:, i));
end
U = zeros(r, 40);
Sw = 0;
Sb = 0;
for i = 1 : 40
   U(:, i) = mean(H(:, Train_num * (i - 1) + 1 : Train_num * i), 2);
   for j = 1 : Train_num
      temp = H(:, Train_num * (i - 1) + j) - U(:, i);
      Sw = Sw + temp' * temp;
   end
   for j = 1 : 40
       temp = U(:, i) - U(:, j);
       Sb = Sb + temp' * temp;
   end
end
Sw = Sw / (C * ni);
Sb = Sb / (C * (C - 1));
J(1) = sum(sum((V.*log(V./(W * H))) - V + W * H)) + alpha * Sw - beta * Sb;%���ۺ���

for iter = 1: maxiter
    Wold = W;
    Hold = H;
    
    b = zeros(r, Train_num * 40);
    for i = 1 : r
        for j = 1 : Train_num * 40
            tempj = 0;
            for k = 1 : C
                if(ceil(j / ni)~= k)
                    tempC = U(i, k) - (U(i, ceil(j / ni)) - Hold(i, j) / ni);
                    tempj = tempj + tempC;
                end
            end
            b(i, j) = 4 / (ni * C * (C - 1)) * tempj -...
                2 / (ni * C) * U(i, ceil(j / ni)) + 1;
        end
    end
    
    Vc = V./(Wold * Hold);                                                 %����W��H
    H = -b + sqrt(b.*b + 4 * constH * (Hold.*(Vc'*Wold)'));                                         
%     W = Wold.*(Vc * H')./(repmat(sum(Wold, 2), [1, r]) + ...
%         repmat(sum(H', 1), [m_img * n_img, 1]));
    W = Wold.*(Vc * H')./(repmat(sum(H', 1), [m_img * n_img, 1]));

%     for i = 1 : r                                                          %��W���и���ģΪ1��Լ��
%         W(:, i) = W(:, i) / norm(W(:, i), 2);
%     end    
    
    for i = 1 : 40                                                         %���´��ۺ���
        U(:, i) = mean(H(:, Train_num * (i - 1) + 1 : Train_num * i), 2);
        for j = 1 : Train_num
            temp = H(:, Train_num * (i - 1) + j) - U(:, i);
            Sw = Sw + temp' * temp;
        end
        for j = 1 : 40
            temp = U(:, i) - U(:, j);
            Sb = Sb + temp' * temp;
        end
    end
    Sw = Sw / (C * ni);
    Sb = Sb / (C * (C - 1));
    J(iter) = sum(sum((V.*log(V./(W * H))) - V + W * H)) + ...
        alpha * Sw - beta * Sb;               
end
%������ۺ���������
figure;
plot([1 : maxiter], J);
figure;
for i = 1 : r / 2
    subplot(8, 8, i);
    im = reshape(1- W(:, i), m_img, n_img); 
    imagesc(im);colormap('gray');  
end
figure;
for i = 1 : r / 2
    subplot(8, 8, i);
    im = reshape(1- W(:, i + r / 2), m_img, n_img); 
    imagesc(im);colormap('gray');  
end
%% ����
%���������������ݱ�ʾΪW��ʸ�����������
Ht = abs(randn(r, Test_num * 40));
Hold = Ht;
for iter = 1: maxiter
    b = zeros(r, Test_num * 40);
    for i = 1 : r
        for j = 1 : Test_num * 40
            tempj = 0;
            for k = 1 : C
                if(ceil(j / 2)~= k)
                    tempC = U(i, k) - (U(i, ceil(j / 2)) - Hold(i, j) / 2);
                    tempj = tempj + tempC;
                end
            end
            b(i, j) = 4 / (2 * C * (C - 1)) * tempj -...
                2 / (2 * C) * U(i, ceil(j / 2)) + 1;
        end
    end
    Tc = T./(Wold * Hold);                                                 %����H
    Ht = -b + sqrt(b.*b + 4 * constH * (Hold.*(Tc'*Wold)')); 
%     Ht = sqrt(Hold.*(W' * (T./(W * Hold))));                               %����H

    for i = 1 : 40                                                         %���´��ۺ���
        U(:, i) = mean(Ht(:, Test_num * (i - 1) + 1 : Test_num * i), 2);
    end
end
VT = W * Ht;                                                               %�ع�ͼ
%����ع�ͼ
for i = 1 : Test_num * 40
    if mod(i, 20) == 1
        figure;
        m = 1;
    end
    subplot(4, 5, m);
    im = reshape(VT(:, i), m_img, n_img); 
    imagesc(im);colormap('gray');  
    m = m + 1;
end
%����ƥ����
right = 0;
dist = zeros(1, Train_num * 40);
class_recT = zeros(40 * Test_num, 1);
for i = 1 : Test_num * 40
    for j = 1 : Train_num * 40
        dist(j) = norm(Ht(:, i) - H(:, j))^2;                              %ѡȡϵ����ŷ�Ͼ����������Ϊʶ�����
    end
    [mindist index] = sort(dist);
    class_recT(i) = class_V(index(1));
end
for i = 1 : Test_num * 40                                                  %ͳ��ʶ����
    if class_recT(i) == class_T(i)
        right = right + 1;
    end
end
display(right / (Test_num * 40));
rc = right / (Test_num * 40);

