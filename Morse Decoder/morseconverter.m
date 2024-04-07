clc
load data.mat

% Read an input wave file containing Morse code

[y, Fs] = audioread('morseCode1.wav');
%[y, Fs] = audioread('morseCode2.wav');
%[y, Fs] = audioread('morseCode3.wav');
%[y, Fs] = audioread('morseCode4.wav');

% Plot the sampled data

figure;
subplot(2, 1, 1);
plot(y);
title('Input wave file containing Morse code');

% Numar total de esantioane din y (numarul de elemente ale vectorului y)
% N reprezinta produsul dintre Fs si durata semnalului in secunde

N = length(y);

% Durata in secunde a semnalului

durata = N / Fs;

% Folosind standardul CODEX, cu WPM = 10, obtinem 60 dots in cuvant
% Aplicand formula, rezulta 0.1 secunde pentru un dot, deci o unitate de
% timp de 0.1 secunde

dot = 0.1;

% Fs este frecventa de esantionare, adica numarul de esantioane pe unitate
% de timp (1 secunda)
% Produsul dintre unitatea de timp in Morse, adica 0,1 secunde si Fs va
% corespunde numarului de esantioane dintr-o unitate, pe care o numim
% segment

nr_esantioane_dot = dot * Fs;

% Duratele celorlalte simboluri au fost determinate aplicand regulile
% codului Morse
% Durata dash-ului este de 3 unitati de timp, deci 0.1 * 3 = 0.3 secunde
% Durata spatiului dintre dots si dashes din interiorul unui caracter 
% codificat este de 1 unitate de timp, deci 0.1 secunde
% Durata spatiului dintre caractere codificate este de 3 unitati de timp,
% deci 0.1 * 3 = 0.3 secunde
% Durata spatiului dintre cuvinte este de 7 unitati de timp, deci 0.1 * 7 =
% 0.7 secunde 

% Numărul total de segmente de 0,1 secunde in audio-ul nostru este raportul
% dintre N = length(y), adica numarul total de esantioane din fisierul
% audio si nr_esantioane_dot, adica numarul de esantioane dintr-un segment

segmente = N / nr_esantioane_dot;

% mCode este vectorul in care vor fi puse caracterele descifrate

mCode = ''; 

% Definim o variabila care retine fiecare segment care poate fi parte
% dintr-un spatiu

spatiu = 0;

% Definim o variabila care retine fiecare segment care poate fi parte
% dintr-un dash

dash = 0;

% Parcurgem fiecare segment in care a fost impartit y

for i = 1 : segmente

    % Calculam care sunt indecsii intre care se incadreaza segmentul pe
    % care il verificam 

    inceputul_segmentului = (i - 1) * nr_esantioane_dot + 1;
    sfarsitul_segmentului = inceputul_segmentului + nr_esantioane_dot - 1;
        
    % Definim segmentul pe care il verificam intre indecsi

    segment = y(inceputul_segmentului : sfarsitul_segmentului);

    disp(['Indecsi segment cu nr ', num2str(i), ': ', num2str(inceputul_segmentului), ' ', num2str(sfarsitul_segmentului)]);

    % Calculam modulul amplitudinii segmentului, pentru ca aceasta poate
    % lua valori de la -1 la 1

    modul = abs(segment);

    % Calculam care este amplitudinea maxima din modulul curent

    amp_maxima = max(modul);

    % Afisarea valorii amplitudinii maxime pentru segmentul curent
    disp(['Amplitudinea maxima pentru segmentul ', num2str(i), ': ', num2str(amp_maxima)]);

    % Definim segmentele de langa segmentul verificat
    % Daca i are valoarea 1, deci segmentul curent este chiar primul, nu
    % definim segmentul anterior, pentru ca nu exista

    if i > 1
        
        inceputul_segmentului_anterior = inceputul_segmentului - nr_esantioane_dot;
        sfarsitul_segmentului_anterior = inceputul_segmentului_anterior + nr_esantioane_dot - 1;

        segment_anterior = y(inceputul_segmentului_anterior : sfarsitul_segmentului_anterior);

        disp(['Indecsi segment anterior inainte de segment cu nr ', num2str(i), ': ', num2str(inceputul_segmentului_anterior), ' ', num2str(sfarsitul_segmentului_anterior)]);

        % Calculam modulul segmentului anterior

        modul_anterior = abs(segment_anterior);

        % Calculam amplitudinea maxima din acest modul

        amp_maxima_anterior = max(modul_anterior);

    end

    % Daca i are valoarea segmente, deci segmentul curent este chiar
    % ultimul, nu definim segmentul urmator, pentru ca nu exista

    if i < segmente 

         inceputul_segmentului_urmator = inceputul_segmentului + nr_esantioane_dot;
         sfarsitul_segmentului_urmator = inceputul_segmentului_urmator + nr_esantioane_dot - 1;

         disp(['Indecsi segment urmator dupa segment cu nr ', num2str(i), ': ', num2str(inceputul_segmentului_urmator), ' ', num2str(sfarsitul_segmentului_urmator)]);

         segment_urmator = y(inceputul_segmentului_urmator : sfarsitul_segmentului_urmator);

         % Calculam modulul acestui segment

         modul_urmator = abs(segment_urmator);

         % Calculam amplitudinea maxima din acest modul

         amp_maxima_urmator = max(modul_urmator);

    end

    % Verificam segmentele si le descifram

    % Primul segment il verificam separat, pentru ca nu are un segment
    % anterior

    if i == 1

        % Verific sa nu ma aflu pe spatiu

        if amp_maxima == 1
            % Verific daca am dot 

            if amp_maxima_urmator == 0
                mCode = [mCode '.'];

            % Ma aflu in dash

            else
                dash = dash + 1;
            end
            
        % Ma aflu pe spatiu
        else 
            spatiu = spatiu + 1;
        end
    elseif i == segmente
        % Verific sa nu ma aflu pe spatiu
        if amp_maxima == 1
            % Verific daca sunt dot 
            if amp_maxima_anterior == 0
                mCode = [mCode '.'];
            elseif dash == 2
                mCode = [mCode '-'];
            end
        else
            if spatiu == 2
                mCode = [mCode ' '];
                spatiu = 0;
            elseif spatiu > 2
                mCode = [mCode '/'];
            end
        end
    else
        % Verific sa nu ma aflu pe spatiu
        if amp_maxima == 1
            % dash ia 3 valori: 
            % 1. 0 daca asta e primul segment cu amplitudine 1 dupa
            % unul cu amplitudine 0 
            % 2. 1 daca segmentul de dinainte a avut amplitudine 1 
            % 3. 2 daca celelalte doua segmente de dinainte au avut
            % amplitudine 1, deci aici se incheie dash-ul

            % Verific daca e dot
            if (dash == 0) && (amp_maxima_urmator == 0)
                mCode = [mCode '.'];
            % Verific daca aici incepe un dash, daca da, adaug 1 la dash ca
            % sa semnific inceputul
            elseif (dash == 0) && (amp_maxima_urmator == 1)
                dash = dash + 1;
            % Verific daca asta e al doilea segment din dash, daca da,
            % adaug 1 
            elseif (dash == 1) 
                dash = dash + 1;
            % Verific daca asta e ultimul segment din dash, daca da, il pun
            % in mCode si resetez variabila dash
            elseif (dash == 2)
                mCode = [mCode '-'];
                dash = 0;
            end
        else
            % spatiu ia mai multe valori: 
            % 1. 0 daca asta e primul segment cu amplitudine 0 dupa unul 
            % cu amplitudine 1
            % 2. 1 daca inainte de acest segment este un segment cu
            % amplitudine 0
            % 3. 2 daca inainte de acest segment sunt 2 segmente cu
            % amplitudine 0
            % 4. 3 daca deja separ cuvinte
            if (spatiu == 0) && (amp_maxima_urmator == 0)
                spatiu = spatiu + 1;
            elseif (spatiu == 1)
                spatiu = spatiu + 1;
            elseif (spatiu == 2) && (amp_maxima_urmator == 1)
                mCode = [mCode ' '];
                spatiu = 0;
            elseif (spatiu == 2) && (amp_maxima_urmator == 0)
                mCode = [mCode ' '];
                spatiu = spatiu + 1;
            elseif (spatiu == 3)
                mCode = [mCode '/'];
                spatiu = 0;
            end
        end
    end
end
        
disp(['Codul Morse obținut: ', mCode]);

%decode morse to text (do not change this part!!!)
%mCode = '-.. ... .--. .-.. .- -... ... ';
deco = [];
mCode = [mCode ' '];	%mCode is an array containing the morse characters to be decoded to text
lCode = [];

for j=1:length(mCode)
    if(strcmp(mCode(j),' ') || strcmp(mCode(j),'/'))
        for i=double('a'):double('z')
            letter = getfield(morse,char(i));
            if strcmp(lCode, letter)
                deco = [deco char(i)];
            end
        end
        for i=0:9
            numb = getfield(morse,['nr',num2str(i)]);
            if strcmp(lCode, numb)
                deco = [deco, num2str(i)];
            end
        end
        lCode = [];
    else
        lCode = [lCode mCode(j)];
    end
    if strcmp(mCode(j),'/')
        deco = [deco ' '];
    end
end

fprintf('Decode : %s \n', deco);






        















