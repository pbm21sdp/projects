clc
load data.mat

%decode sound to morse

	%your code goes here!!!

% Read an input wave file containing Morse code

%[y, Fs] = audioread('morseCode1.wav');
[y, Fs] = audioread('morseCode2.wav');
%[y, Fs] = audioread('morseCode3.wav');
%[y, Fs] = audioread('morseCode4.wav');

% Plot the sampled data

figure;
subplot(1, 1, 1);
plot(y);
title('Input wave file containing Morse code');

% Numar total de esantioane din y (numarul de elemente ale vectorului y)
% N reprezinta produsul dintre Fs si durata semnalului in secunde

N = length(y);

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
% dintre N = length(y), adica numarul total de esantioane din y 
% si nr_esantioane_dot, adica numarul de esantioane dintr-un segment

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
    
    inceputul_segmentului = (i - 1) * nr_esantioane_dot + 1;
    sfarsitul_segmentului = inceputul_segmentului + nr_esantioane_dot - 1;

    segment = y(inceputul_segmentului : sfarsitul_segmentului);

    modul = abs(segment);
    amp_maxima = max(modul);

    if i > 1
      
        inceputul_segmentului_anterior = inceputul_segmentului - nr_esantioane_dot;
        sfarsitul_segmentului_anterior = inceputul_segmentului_anterior + nr_esantioane_dot - 1;

        segment_anterior = y(inceputul_segmentului_anterior : sfarsitul_segmentului_anterior);

        modul_anterior = abs(segment_anterior);
        amp_maxima_anterior = max(modul_anterior);

    end

    if i < segmente 

         inceputul_segmentului_urmator = inceputul_segmentului + nr_esantioane_dot;
         sfarsitul_segmentului_urmator = inceputul_segmentului_urmator + nr_esantioane_dot - 1;

         segment_urmator = y(inceputul_segmentului_urmator : sfarsitul_segmentului_urmator);

         modul_urmator = abs(segment_urmator);
         amp_maxima_urmator = max(modul_urmator);

    end

    if i == 1
        if amp_maxima == 1
            if amp_maxima_urmator == 0
                mCode = [mCode '.'];
            else
                dash = dash + 1;
            end

        else 
            spatiu = spatiu + 1;
        end

    elseif i == segmente
        if amp_maxima == 1
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
        if amp_maxima == 1
            if (dash == 0) && (amp_maxima_urmator == 0)
                mCode = [mCode '.'];
            elseif (dash == 0) && (amp_maxima_urmator == 1)
                dash = dash + 1;
            elseif (dash == 1) 
                dash = dash + 1;
            elseif (dash == 2)
                mCode = [mCode '-'];
                dash = 0;
            end

        else
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