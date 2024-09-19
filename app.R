# GDPoweR Project - Polish application for UBER (and other platforms) data visualisation
# Wojciech Szymczak - Institute for Structural Research (IBS) 
# One should be able to do use the app on the desktop, as long as one is able to provide working directory to ShinyApp folder
# setwd("C:/Users/wojci/IBS Dropbox/Wojciech Szymczak") #insert working directory here 
######################## L I B R A R I E S ####################################

# Read libraries
library(tidyverse)
library(lubridate)
library(plotly)
library(shinymanager)
library(rsconnect)
library(shiny)
library(bslib)
library(bsicons)
library(DT)
library(grDevices)
library(shiny.fluent)
library(rclipboard)
library(shinylive)



########################## C L E A N  E N V I R O N M E N T #############################  
rm(list = ls())

# define some basic credentials (on data.frame)
credentials <- data.frame(
  user = c("kierowca1", "kierowca2"), # mandatory
  password = c("uber_pyszne", "uber_pyszne"), # mandatory
  start = c("2019-04-15"), # optinal (all others)
  expire = c(NA, "2024-12-31"),
  admin = c(FALSE, TRUE),
  comment = "Simple and secure authentification mechanism 
  for single ‘Shiny’ applications.",
  stringsAsFactors = FALSE
)


CSS <- "
.morecontent {
    display: none; /* The hidden part of the text should not be shown initially */
}
.morelink {
    display: block; /* The link to toggle text visibility should be visible */
    cursor: pointer; /* Show a pointer cursor when hovering over the link */
    color: blue; /* Optional: change the link color */
    text-decoration: underline; /* Optional: underline the link */
}
"

JS <- '
$(document).ready(function() {
    var showChar = 100;  // Number of characters to show by default
    var ellipsestext = "...";
    var moretext = "Pokaż więcej>";
    var lesstext = "Pokaż mniej";

    $(".more").each(function() {
        var content = $(this).html();
        
        // If the content is longer than the showChar limit
        if (content.length > showChar) {
            var visibleContent = content.substr(0, showChar); // Visible part
            var hiddenContent = content.substr(showChar); // Hidden part
            
            // Combine visible and hidden content with a toggle link
            var html = visibleContent + "<span class=:moreellipses">" + ellipsestext 
                        + "</span><span class="morecontent">" + hiddenContent 
                        + "</span><a href="#" class="morelink">" + moretext + "</a>";

$(this).html(html);  // Replace the original HTML content
}
});

$(".morelink").click(function(event) {
  event.preventDefault();  // Prevent default anchor behavior
  
  var moreLink = $(this);
  var moreContent = moreLink.prev(".morecontent");
  var moreEllipses = moreLink.prev(".moreellipses");
  
  // Toggle visibility
  moreContent.toggle();
  moreEllipses.toggle();
  
  // Switch the link text
  if (moreContent.is(":visible")) {
    moreLink.text(lesstext);  // Show "Pokaż mniej"
  } else {
    moreLink.text(moretext);  // Show "Pokaż więcej"
  }
});
});
'

########################## U S E R  I N T E R F A C E ####################################
# Define UI

ui <- bslib::page_navbar(
  tags$head(
    tags$style(
      HTML(".shiny-notification {
             position:fixed;
             top: calc(50%);
             left: calc(50%);
             }
             "
      ),
      tags$style(HTML(CSS)), 
      tags$script(HTML(JS))
    )
  ),
  theme = bs_theme(bootswatch = "simplex", primary = "#B6163A", 
                   base_font = font_google("Roboto")),
  title = "Posumowanie danych",
  sidebar = sidebar(
    HTML('<img src = "GDPOWER_RGB_LOGO.png" height = "auto">'),
    HTML('<img src = "EU.jpg" height = "auto">')
  ),
  nav_panel("Informacje o aplikacji",
            h3("O projekcie GDPoweR"),
            p(
              "Projekt GDPoweR ma na celu wzmocnienie dialogu społecznego w gospodarce platformowej. 
  Badacze będą analizować strategie wykorzystywane przez pracowników platformowych, aktywistów, 
  związkowców i pracodawców w negocjacjach dotyczących wynagrodzeń i warunków pracy.Celem projektu jest również zwiększenie świadomości praktyki zbierania danych przez firmy i 
  umożliwienie pracownikom odzyskiwanie swoich danych. Projekt przyczyni się także
  do kształtowania lepszej polityki w tym zakresie na szczeblu lokalnym oraz na szczeblu 
  europejskim.",style="text-align: justify;"),
            HTML('
            <h3>Jak dziala aplikacja?</h3>
              <p>Aplikacja zostala przygotowana, aby ulatwić analizę danych uzyskanych od platform, takich jak UBER, Pyszne.pl, Bolt etc. Na tej podstawie można szybko i latwo uzyskać informację o m.in:</p>
              <ul>
              <li>Liczbie wykonanych przejazdow</li>
              <li>Średniej kwocie uzyskanej za przejazd</li>
              </ul>
              <p>Aby przeanalizować uzyskane dane, wystarczy przygotować dane zdobyte od platform (na ten moment aplikacja obsluguje dane od Uber i Pyszne.pl).</p>
              <ol>
              <li>Po wejściu na stronę startową aplikacji należy wybrać interesującą nas zakladkę</li>
              <p><img src = "krok1.png" height = "200px"></p>
              <p></p>
              <li>W następnym kroku należy wproadzić dane (wszystkie wymagane pliki muszą być wprowadzone). Jeżeli przez przypadek wprowadzisz blędnie dane, możesz sprobować raz jeszcze.</li>
              <p><img src = "krok2.png" height = "300px"></p>
              <p></p>
              <li>Analiza danych zostanie automatycznie wyświetlona po wprowadzeniu danych.&nbsp;&nbsp;</li>
              </ol>
              ')
            ),
  nav_panel("Dane z platform",
            HTML('
                 <h3>Jak zaplikować o dane do platform?</h3>'),
            HTML(
              '
              <p style="text-align: justify;"><strong> Uber </strong></p>
              <p style="text-align: justify;">Uber oferuje możliwość podglądu swoich danych w wyszukiwarce, jak i pobrania ich na dysk.</p>
              <p style="text-align: justify;">Pod  <a href="https://myprivacy.uber.com/privacy/exploreyourdata/download">tym linkiem</a>można pobrać swoje dane po zalogowaniu się na swoje konto </p>
              <p style="text-align: justify;">Gdy dane będą gotowe do pobrania, otrzymasz e-mail lub SMS.</p>
              <p style="text-align: justify;">Drugim sposobem jest przesłanie formularza znajdującego się pod tym <a href="https://help.uber.com/riders/article/submit-a-privacy-inquiry?nodeId=489292a2-27ce-42f5-9a47-d4dd017559fd">linkiem.</a></p>
              <p style="text-align: justify;">W okienku "<em>Podaj dodatkowe informacje na temat powodu kontaktu z firmą Uber</em>" można wkleić następującą treść:</p>
                '),
            rclipboardSetup(),
            rclipButton("clipbtn", "Skopiuj wiadomość", "Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. Jest to zarówno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych

Artykuł 20

W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), które obejmuje wszystkie dane, które wygenerowała moja aktywność na platformie oraz które zostały pośrednio zaobserwowane i mnie dotyczą (na których pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:

wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, takim jak plik CSV.
wraz ze zrozumiałym opisem wszystkich zmiennych.
Artykuł 15

W przypadku wszystkich danych osobowych, które nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):

kopię danych przesłanych mi w formacie elektronicznym. Obejmuje to wszelkie dane uzyskane na mój temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, które są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.
Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej.

Mój wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję

dane osobowe w najszerszym znaczeniu, w tym między innymi notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczególny sposób prowadzenia pojazdu, jazdy, chodzenia lub mówienia),
dane wynikające z innych danych, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wspólnych atrybutach itp.)
dane wywnioskowane z innych danych, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytmów i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.
Jeśli Twoja organizacja uważa mnie za administratora danych, które przetwarzacie

Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do których Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi wszystkich danych, które przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środków i celów przetwarzania.

Artykuł 22:

Ponadto proszę o podanie następujących kategorii informacji:

Informacje o zautomatyzowanym podejmowaniu decyzji
Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).

Metadane dotyczące przetwarzania
Wniosek ten obejmuje również metadane, do których mam prawo na mocy RODO.

Informacje o administratorach, podmiotach przetwarzających, źródle i transferach.

Tożsamość wszystkich współadministratorów danych osobowych.
Wszelkie strony trzecie, którym ujawniono dane, wraz z danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c).
Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o źródle tych danych, w tym nazwy i kontaktowego adresu e-mail administratora danych (z jakiego źródła pochodzą dane osobowe, art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).
Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę również o wyszczególnienie podstaw prawnych i zabezpieczeń takich transferów danych).", icon = icon("clipboard")),
            tags$details(
              tags$summary("Wyświetl treść wiadomości"),
              HTML('
              <p><em>Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. </em><em>Jest to zar&oacute;wno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych</em></p>
              <p><strong><em>Artykuł 20</em></strong></p>
              <p><em>W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), kt&oacute;re obejmuje wszystkie dane, kt&oacute;re wygenerowała moja aktywność na platformie oraz kt&oacute;re zostały pośrednio zaobserwowane i mnie dotyczą (na kt&oacute;rych pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:</em></p>
              <ul>
              <li><strong><em>wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, </em></strong><em>takim jak plik CSV. </em></li>
              <li><em>wraz ze <strong>zrozumiałym opisem wszystkich zmiennych.</strong></em></li>
              </ul>
              <p><strong><em>Artykuł 15</em></strong></p>
              <p><em>W przypadku wszystkich danych osobowych, kt&oacute;re nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):</em></p>
              <ul>
              <li><strong><em>kopię danych przesłanych mi w formacie elektronicznym</em></strong><em>. Obejmuje to wszelkie dane uzyskane na m&oacute;j temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, kt&oacute;re są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.</em></li>
              </ul>
              <p><em>Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej. </em></p>
              <p><em>M&oacute;j wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję</em></p>
              <ul>
              <li><strong><em>dane osobowe w najszerszym znaczeniu, w tym między innymi </em></strong><em>notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczeg&oacute;lny spos&oacute;b prowadzenia pojazdu, jazdy, chodzenia lub m&oacute;wienia), </em></li>
              <li><strong><em>dane wynikające z innych danych</em></strong><em>, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wsp&oacute;lnych atrybutach itp.) </em></li>
              <li><strong><em>dane wywnioskowane z innych danych</em></strong><em>, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytm&oacute;w i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.</em></li>
              </ul>
              <p><strong><em>Jeśli Twoja organizacja uważa mnie za administratora danych, kt&oacute;re przetwarzacie</em></strong></p>
              <p><em>Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do kt&oacute;rych Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi <strong>wszystkich danych, kt&oacute;re przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, </strong>zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środk&oacute;w i cel&oacute;w przetwarzania.</em></p>
              <p><strong><em>Artykuł 22:</em></strong></p>
              <p><em>Ponadto proszę o podanie następujących kategorii informacji:</em></p>
              <ol>
              <li><strong><em>Informacje o zautomatyzowanym podejmowaniu decyzji</em></strong></li>
              </ol>
              <p><em>Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).</em></p>
              <ol start="2">
              <li><strong><em>Metadane dotyczące przetwarzania</em></strong></li>
              </ol>
              <p><em>Wniosek ten obejmuje r&oacute;wnież metadane, do kt&oacute;rych mam prawo na mocy RODO. </em></p>
              <p><strong><em>Informacje o administratorach, podmiotach przetwarzających, źr&oacute;dle i transferach. </em></strong></p>
              <ul>
              <li><em>Tożsamość wszystkich wsp&oacute;ładministrator&oacute;w danych osobowych. </em></li>
              <li><em>Wszelkie <strong>strony trzecie, kt&oacute;rym ujawniono dane, wraz z </strong>danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c). </em></li>
              <li><em>Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o <strong>źr&oacute;dle tych danych</strong>, w tym nazwy i kontaktowego adresu e-mail administratora danych ("z jakiego źr&oacute;dła pochodzą dane osobowe", art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).</em></li>
              <li><em>Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, <strong>czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę r&oacute;wnież o wyszczeg&oacute;lnienie podstaw prawnych i zabezpieczeń takich transfer&oacute;w danych).</strong></em></li>
              </ul>
                   ')
            ),
            HTML(
              '<p><strong>BOLT</strong></p>
              <p><a href="https://bolt.eu/pl-pl/privacy/data-subject/">Tutaj</a> dostępny jest formularz umożliwiający pobranie danych:</p>
              <p>W opisie żądania można wpisać tylko 255 znak&oacute;w. Treść może być następująca:</p>
              <p><em>"Niniejszym składam wniosek o dostęp do moich danych zgodnie z RODO. Proszę o dostarczenie kopii wszystkich przechowywanych/przetwarzanych danych w formacie csv ze zrozumiałym opisem wszystkich zmiennych.&nbsp;"</em></p>'
            ),
            HTML(
              '<p><strong>Pyszne.pl</strong></p>
              <p><a href="https://privacyportal-de.onetrust.com/webform/5fffb107-8d8a-49e5-bdda-be5d78615bc7/5e662c3e-31ca-49fe-a8b1-bfef7431a149">Tutaj</a> dostępny jest formularz umożliwiający pobranie danych</p>
              <p>W okienku "<em>Typ wnioskodawcy</em>" należy zaznaczyć "<em>Kurier</em>", a w okienko "<em>Informacje dotyczące wniosku</em>" można wkleić następującą treść:</p>'
            ),
            rclipboardSetup(),
            rclipButton("clipbtn", "Skopiuj wiadomość", "Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. Jest to zarówno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych

Artykuł 20

W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), które obejmuje wszystkie dane, które wygenerowała moja aktywność na platformie oraz które zostały pośrednio zaobserwowane i mnie dotyczą (na których pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:

wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, takim jak plik CSV.
wraz ze zrozumiałym opisem wszystkich zmiennych.
Artykuł 15

W przypadku wszystkich danych osobowych, które nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):

kopię danych przesłanych mi w formacie elektronicznym. Obejmuje to wszelkie dane uzyskane na mój temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, które są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.
Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej.

Mój wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję

dane osobowe w najszerszym znaczeniu, w tym między innymi notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczególny sposób prowadzenia pojazdu, jazdy, chodzenia lub mówienia),
dane wynikające z innych danych, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wspólnych atrybutach itp.)
dane wywnioskowane z innych danych, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytmów i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.
Jeśli Twoja organizacja uważa mnie za administratora danych, które przetwarzacie

Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do których Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi wszystkich danych, które przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środków i celów przetwarzania.

Artykuł 22:

Ponadto proszę o podanie następujących kategorii informacji:

Informacje o zautomatyzowanym podejmowaniu decyzji
Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).

Metadane dotyczące przetwarzania
Wniosek ten obejmuje również metadane, do których mam prawo na mocy RODO.

Informacje o administratorach, podmiotach przetwarzających, źródle i transferach.

Tożsamość wszystkich współadministratorów danych osobowych.
Wszelkie strony trzecie, którym ujawniono dane, wraz z danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c).
Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o źródle tych danych, w tym nazwy i kontaktowego adresu e-mail administratora danych (z jakiego źródła pochodzą dane osobowe, art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).
Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę również o wyszczególnienie podstaw prawnych i zabezpieczeń takich transferów danych).", icon = icon("clipboard")),
            tags$details(
              tags$summary("Wyświetl treść wiadomości"),
              HTML('
              <p><em>Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. </em><em>Jest to zar&oacute;wno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych</em></p>
              <p><strong><em>Artykuł 20</em></strong></p>
              <p><em>W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), kt&oacute;re obejmuje wszystkie dane, kt&oacute;re wygenerowała moja aktywność na platformie oraz kt&oacute;re zostały pośrednio zaobserwowane i mnie dotyczą (na kt&oacute;rych pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:</em></p>
              <ul>
              <li><strong><em>wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, </em></strong><em>takim jak plik CSV. </em></li>
              <li><em>wraz ze <strong>zrozumiałym opisem wszystkich zmiennych.</strong></em></li>
              </ul>
              <p><strong><em>Artykuł 15</em></strong></p>
              <p><em>W przypadku wszystkich danych osobowych, kt&oacute;re nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):</em></p>
              <ul>
              <li><strong><em>kopię danych przesłanych mi w formacie elektronicznym</em></strong><em>. Obejmuje to wszelkie dane uzyskane na m&oacute;j temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, kt&oacute;re są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.</em></li>
              </ul>
              <p><em>Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej. </em></p>
              <p><em>M&oacute;j wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję</em></p>
              <ul>
              <li><strong><em>dane osobowe w najszerszym znaczeniu, w tym między innymi </em></strong><em>notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczeg&oacute;lny spos&oacute;b prowadzenia pojazdu, jazdy, chodzenia lub m&oacute;wienia), </em></li>
              <li><strong><em>dane wynikające z innych danych</em></strong><em>, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wsp&oacute;lnych atrybutach itp.) </em></li>
              <li><strong><em>dane wywnioskowane z innych danych</em></strong><em>, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytm&oacute;w i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.</em></li>
              </ul>
              <p><strong><em>Jeśli Twoja organizacja uważa mnie za administratora danych, kt&oacute;re przetwarzacie</em></strong></p>
              <p><em>Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do kt&oacute;rych Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi <strong>wszystkich danych, kt&oacute;re przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, </strong>zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środk&oacute;w i cel&oacute;w przetwarzania.</em></p>
              <p><strong><em>Artykuł 22:</em></strong></p>
              <p><em>Ponadto proszę o podanie następujących kategorii informacji:</em></p>
              <ol>
              <li><strong><em>Informacje o zautomatyzowanym podejmowaniu decyzji</em></strong></li>
              </ol>
              <p><em>Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).</em></p>
              <ol start="2">
              <li><strong><em>Metadane dotyczące przetwarzania</em></strong></li>
              </ol>
              <p><em>Wniosek ten obejmuje r&oacute;wnież metadane, do kt&oacute;rych mam prawo na mocy RODO. </em></p>
              <p><strong><em>Informacje o administratorach, podmiotach przetwarzających, źr&oacute;dle i transferach. </em></strong></p>
              <ul>
              <li><em>Tożsamość wszystkich wsp&oacute;ładministrator&oacute;w danych osobowych. </em></li>
              <li><em>Wszelkie <strong>strony trzecie, kt&oacute;rym ujawniono dane, wraz z </strong>danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c). </em></li>
              <li><em>Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o <strong>źr&oacute;dle tych danych</strong>, w tym nazwy i kontaktowego adresu e-mail administratora danych ("z jakiego źr&oacute;dła pochodzą dane osobowe", art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).</em></li>
              <li><em>Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, <strong>czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę r&oacute;wnież o wyszczeg&oacute;lnienie podstaw prawnych i zabezpieczeń takich transfer&oacute;w danych).</strong></em></li>
              </ul>
                   ')
            ),
            HTML(
              '<p><strong>Glovo</strong></p>
              <p>Należy skorzystać z formularza <a href="https://www.trustworks.io/glovo/privacy-center-pl">tutaj.</a></p>
              <p>Typ DSR - wybierz "Przenośność danych (Pobierz moje dane)"</p>
              <p>Pow&oacute;d/Komentarz - można wkleić następującą treść:</p>'), 
            rclipboardSetup(),
            rclipButton("clipbtn", "Skopiuj wiadomość", "Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. Jest to zarówno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych

Artykuł 20

W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), które obejmuje wszystkie dane, które wygenerowała moja aktywność na platformie oraz które zostały pośrednio zaobserwowane i mnie dotyczą (na których pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:

wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, takim jak plik CSV.
wraz ze zrozumiałym opisem wszystkich zmiennych.
Artykuł 15

W przypadku wszystkich danych osobowych, które nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):

kopię danych przesłanych mi w formacie elektronicznym. Obejmuje to wszelkie dane uzyskane na mój temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, które są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.
Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej.

Mój wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję

dane osobowe w najszerszym znaczeniu, w tym między innymi notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczególny sposób prowadzenia pojazdu, jazdy, chodzenia lub mówienia),
dane wynikające z innych danych, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wspólnych atrybutach itp.)
dane wywnioskowane z innych danych, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytmów i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.
Jeśli Twoja organizacja uważa mnie za administratora danych, które przetwarzacie

Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do których Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi wszystkich danych, które przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środków i celów przetwarzania.

Artykuł 22:

Ponadto proszę o podanie następujących kategorii informacji:

Informacje o zautomatyzowanym podejmowaniu decyzji
Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).

Metadane dotyczące przetwarzania
Wniosek ten obejmuje również metadane, do których mam prawo na mocy RODO.

Informacje o administratorach, podmiotach przetwarzających, źródle i transferach.

Tożsamość wszystkich współadministratorów danych osobowych.
Wszelkie strony trzecie, którym ujawniono dane, wraz z danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c).
Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o źródle tych danych, w tym nazwy i kontaktowego adresu e-mail administratora danych (z jakiego źródła pochodzą dane osobowe, art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).
Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę również o wyszczególnienie podstaw prawnych i zabezpieczeń takich transferów danych).", icon = icon("clipboard")),
            tags$details(
              tags$summary("Wyświetl treść wiadomości"),
              HTML('
              <p><em>Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. </em><em>Jest to zar&oacute;wno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych</em></p>
              <p><strong><em>Artykuł 20</em></strong></p>
              <p><em>W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), kt&oacute;re obejmuje wszystkie dane, kt&oacute;re wygenerowała moja aktywność na platformie oraz kt&oacute;re zostały pośrednio zaobserwowane i mnie dotyczą (na kt&oacute;rych pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:</em></p>
              <ul>
              <li><strong><em>wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, </em></strong><em>takim jak plik CSV. </em></li>
              <li><em>wraz ze <strong>zrozumiałym opisem wszystkich zmiennych.</strong></em></li>
              </ul>
              <p><strong><em>Artykuł 15</em></strong></p>
              <p><em>W przypadku wszystkich danych osobowych, kt&oacute;re nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):</em></p>
              <ul>
              <li><strong><em>kopię danych przesłanych mi w formacie elektronicznym</em></strong><em>. Obejmuje to wszelkie dane uzyskane na m&oacute;j temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, kt&oacute;re są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.</em></li>
              </ul>
              <p><em>Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej. </em></p>
              <p><em>M&oacute;j wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję</em></p>
              <ul>
              <li><strong><em>dane osobowe w najszerszym znaczeniu, w tym między innymi </em></strong><em>notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczeg&oacute;lny spos&oacute;b prowadzenia pojazdu, jazdy, chodzenia lub m&oacute;wienia), </em></li>
              <li><strong><em>dane wynikające z innych danych</em></strong><em>, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wsp&oacute;lnych atrybutach itp.) </em></li>
              <li><strong><em>dane wywnioskowane z innych danych</em></strong><em>, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytm&oacute;w i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.</em></li>
              </ul>
              <p><strong><em>Jeśli Twoja organizacja uważa mnie za administratora danych, kt&oacute;re przetwarzacie</em></strong></p>
              <p><em>Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do kt&oacute;rych Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi <strong>wszystkich danych, kt&oacute;re przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, </strong>zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środk&oacute;w i cel&oacute;w przetwarzania.</em></p>
              <p><strong><em>Artykuł 22:</em></strong></p>
              <p><em>Ponadto proszę o podanie następujących kategorii informacji:</em></p>
              <ol>
              <li><strong><em>Informacje o zautomatyzowanym podejmowaniu decyzji</em></strong></li>
              </ol>
              <p><em>Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).</em></p>
              <ol start="2">
              <li><strong><em>Metadane dotyczące przetwarzania</em></strong></li>
              </ol>
              <p><em>Wniosek ten obejmuje r&oacute;wnież metadane, do kt&oacute;rych mam prawo na mocy RODO. </em></p>
              <p><strong><em>Informacje o administratorach, podmiotach przetwarzających, źr&oacute;dle i transferach. </em></strong></p>
              <ul>
              <li><em>Tożsamość wszystkich wsp&oacute;ładministrator&oacute;w danych osobowych. </em></li>
              <li><em>Wszelkie <strong>strony trzecie, kt&oacute;rym ujawniono dane, wraz z </strong>danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c). </em></li>
              <li><em>Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o <strong>źr&oacute;dle tych danych</strong>, w tym nazwy i kontaktowego adresu e-mail administratora danych ("z jakiego źr&oacute;dła pochodzą dane osobowe", art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).</em></li>
              <li><em>Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, <strong>czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę r&oacute;wnież o wyszczeg&oacute;lnienie podstaw prawnych i zabezpieczeń takich transfer&oacute;w danych).</strong></em></li>
              </ul>
                   ')
            ),
            HTML('<p>Alternatywnym sposobem jest wklejenie powyższej treści w e-mail wysłany na adres gdpr@glovoapp.com.</p>'
            ),
            HTML(
              '
              <p><strong>Wolt</strong></p>
              <p>Należy wkleić następującą treść w mail wysłany na adres <a href="mailto:privacy@wolt.com">privacy@wolt.com.&nbsp;</a></p>'
            ),
            rclipboardSetup(),
            rclipButton("clipbtn", "Skopiuj wiadomość", "Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. Jest to zarówno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych

Artykuł 20

W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), które obejmuje wszystkie dane, które wygenerowała moja aktywność na platformie oraz które zostały pośrednio zaobserwowane i mnie dotyczą (na których pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:

wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, takim jak plik CSV.
wraz ze zrozumiałym opisem wszystkich zmiennych.
Artykuł 15

W przypadku wszystkich danych osobowych, które nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):

kopię danych przesłanych mi w formacie elektronicznym. Obejmuje to wszelkie dane uzyskane na mój temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, które są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.
Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej.

Mój wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję

dane osobowe w najszerszym znaczeniu, w tym między innymi notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczególny sposób prowadzenia pojazdu, jazdy, chodzenia lub mówienia),
dane wynikające z innych danych, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wspólnych atrybutach itp.)
dane wywnioskowane z innych danych, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytmów i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.
Jeśli Twoja organizacja uważa mnie za administratora danych, które przetwarzacie

Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do których Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi wszystkich danych, które przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środków i celów przetwarzania.

Artykuł 22:

Ponadto proszę o podanie następujących kategorii informacji:

Informacje o zautomatyzowanym podejmowaniu decyzji
Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).

Metadane dotyczące przetwarzania
Wniosek ten obejmuje również metadane, do których mam prawo na mocy RODO.

Informacje o administratorach, podmiotach przetwarzających, źródle i transferach.

Tożsamość wszystkich współadministratorów danych osobowych.
Wszelkie strony trzecie, którym ujawniono dane, wraz z danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c).
Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o źródle tych danych, w tym nazwy i kontaktowego adresu e-mail administratora danych (z jakiego źródła pochodzą dane osobowe, art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).
Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę również o wyszczególnienie podstaw prawnych i zabezpieczeń takich transferów danych).", icon = icon("clipboard")),
            
            tags$details(
              tags$summary("Wyświetl treść wiadomości"),
              HTML('
              <p><em>Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. </em><em>Jest to zar&oacute;wno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych</em></p>
              <p><strong><em>Artykuł 20</em></strong></p>
              <p><em>W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), kt&oacute;re obejmuje wszystkie dane, kt&oacute;re wygenerowała moja aktywność na platformie oraz kt&oacute;re zostały pośrednio zaobserwowane i mnie dotyczą (na kt&oacute;rych pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:</em></p>
              <ul>
              <li><strong><em>wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, </em></strong><em>takim jak plik CSV. </em></li>
              <li><em>wraz ze <strong>zrozumiałym opisem wszystkich zmiennych.</strong></em></li>
              </ul>
              <p><strong><em>Artykuł 15</em></strong></p>
              <p><em>W przypadku wszystkich danych osobowych, kt&oacute;re nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):</em></p>
              <ul>
              <li><strong><em>kopię danych przesłanych mi w formacie elektronicznym</em></strong><em>. Obejmuje to wszelkie dane uzyskane na m&oacute;j temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, kt&oacute;re są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.</em></li>
              </ul>
              <p><em>Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej. </em></p>
              <p><em>M&oacute;j wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję</em></p>
              <ul>
              <li><strong><em>dane osobowe w najszerszym znaczeniu, w tym między innymi </em></strong><em>notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczeg&oacute;lny spos&oacute;b prowadzenia pojazdu, jazdy, chodzenia lub m&oacute;wienia), </em></li>
              <li><strong><em>dane wynikające z innych danych</em></strong><em>, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wsp&oacute;lnych atrybutach itp.) </em></li>
              <li><strong><em>dane wywnioskowane z innych danych</em></strong><em>, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytm&oacute;w i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.</em></li>
              </ul>
              <p><strong><em>Jeśli Twoja organizacja uważa mnie za administratora danych, kt&oacute;re przetwarzacie</em></strong></p>
              <p><em>Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do kt&oacute;rych Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi <strong>wszystkich danych, kt&oacute;re przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, </strong>zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środk&oacute;w i cel&oacute;w przetwarzania.</em></p>
              <p><strong><em>Artykuł 22:</em></strong></p>
              <p><em>Ponadto proszę o podanie następujących kategorii informacji:</em></p>
              <ol>
              <li><strong><em>Informacje o zautomatyzowanym podejmowaniu decyzji</em></strong></li>
              </ol>
              <p><em>Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).</em></p>
              <ol start="2">
              <li><strong><em>Metadane dotyczące przetwarzania</em></strong></li>
              </ol>
              <p><em>Wniosek ten obejmuje r&oacute;wnież metadane, do kt&oacute;rych mam prawo na mocy RODO. </em></p>
              <p><strong><em>Informacje o administratorach, podmiotach przetwarzających, źr&oacute;dle i transferach. </em></strong></p>
              <ul>
              <li><em>Tożsamość wszystkich wsp&oacute;ładministrator&oacute;w danych osobowych. </em></li>
              <li><em>Wszelkie <strong>strony trzecie, kt&oacute;rym ujawniono dane, wraz z </strong>danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c). </em></li>
              <li><em>Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o <strong>źr&oacute;dle tych danych</strong>, w tym nazwy i kontaktowego adresu e-mail administratora danych ("z jakiego źr&oacute;dła pochodzą dane osobowe", art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).</em></li>
              <li><em>Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, <strong>czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę r&oacute;wnież o wyszczeg&oacute;lnienie podstaw prawnych i zabezpieczeń takich transfer&oacute;w danych).</strong></em></li>
              </ul>
                   ')
            ),
            HTML('
            <p><strong>FreeNow</strong></p>
            <p>Należy skorzystać z formularza dostępnego <a href="https://support.free-now.com/hc/pl/requests/new">tutaj</a>.</p>
            <p>W okienku temat można wpisać "DSR - wniosek o pobranie moich danych", a w okienku "Jak możemy Ci pom&oacute;c" należy wkleić następującą treść</p>
                 '),
            rclipboardSetup(),
            rclipButton("clipbtn", "Skopiuj wiadomość", "Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. Jest to zarówno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych

Artykuł 20

W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), które obejmuje wszystkie dane, które wygenerowała moja aktywność na platformie oraz które zostały pośrednio zaobserwowane i mnie dotyczą (na których pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:

wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, takim jak plik CSV.
wraz ze zrozumiałym opisem wszystkich zmiennych.
Artykuł 15

W przypadku wszystkich danych osobowych, które nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):

kopię danych przesłanych mi w formacie elektronicznym. Obejmuje to wszelkie dane uzyskane na mój temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, które są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.
Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej.

Mój wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję

dane osobowe w najszerszym znaczeniu, w tym między innymi notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczególny sposób prowadzenia pojazdu, jazdy, chodzenia lub mówienia),
dane wynikające z innych danych, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wspólnych atrybutach itp.)
dane wywnioskowane z innych danych, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytmów i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.
Jeśli Twoja organizacja uważa mnie za administratora danych, które przetwarzacie

Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do których Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi wszystkich danych, które przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środków i celów przetwarzania.

Artykuł 22:

Ponadto proszę o podanie następujących kategorii informacji:

Informacje o zautomatyzowanym podejmowaniu decyzji
Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).

Metadane dotyczące przetwarzania
Wniosek ten obejmuje również metadane, do których mam prawo na mocy RODO.

Informacje o administratorach, podmiotach przetwarzających, źródle i transferach.

Tożsamość wszystkich współadministratorów danych osobowych.
Wszelkie strony trzecie, którym ujawniono dane, wraz z danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c).
Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o źródle tych danych, w tym nazwy i kontaktowego adresu e-mail administratora danych (z jakiego źródła pochodzą dane osobowe, art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).
Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę również o wyszczególnienie podstaw prawnych i zabezpieczeń takich transferów danych).", icon = icon("clipboard")),
            
            tags$details(
              tags$summary("Wyświetl treść wiadomości"),
              HTML('
              <p><em>Proszę o dostarczenie kopii wszystkich przechowywanych i/lub przetwarzanych danych osobowych. </em><em>Jest to zar&oacute;wno wniosek o dostęp do danych, jak i wniosek o przeniesienie danych</em></p>
              <p><strong><em>Artykuł 20</em></strong></p>
              <p><em>W przypadku danych objętych prawem do przenoszenia danych (RODO, art. 20), kt&oacute;re obejmuje wszystkie dane, kt&oacute;re wygenerowała moja aktywność na platformie oraz kt&oacute;re zostały pośrednio zaobserwowane i mnie dotyczą (na kt&oacute;rych pozyskanie wyraziłem zgodę w umowie lub zgodzie wyświetlonej w aplikacji) chcę otrzymać dane:</em></p>
              <ul>
              <li><strong><em>wysłane do mnie w powszechnie używanym, ustrukturyzowanym formacie nadającym się do odczytu maszynowego, </em></strong><em>takim jak plik CSV. </em></li>
              <li><em>wraz ze <strong>zrozumiałym opisem wszystkich zmiennych.</strong></em></li>
              </ul>
              <p><strong><em>Artykuł 15</em></strong></p>
              <p><em>W przypadku wszystkich danych osobowych, kt&oacute;re nie podlegają przenoszeniu, chciałbym zażądać, w ramach prawa dostępu (RODO, art. 15):</em></p>
              <ul>
              <li><strong><em>kopię danych przesłanych mi w formacie elektronicznym</em></strong><em>. Obejmuje to wszelkie dane uzyskane na m&oacute;j temat, takie jak opinie, wnioski, ustawienia i preferencje. W przypadku danych, kt&oacute;re są dostępne dla administratora (platformy) w formacie nadającym się do odczytu automatycznego, muszą one zostać mi przekazane w tej formie zgodnie z zasadą uczciwości i zapewnienia ochrony danych już w fazie projektowania.</em></li>
              </ul>
              <p><em>Jak wiadomo, pojęcie danych osobowych należy interpretować niezwykle szeroko, zgodnie m.in. z opiniami Grupy Roboczej Art. 29, wytycznymi Europejskiej Rady Ochrony Danych, orzecznictwem Trybunału Sprawiedliwości Unii Europejskiej. </em></p>
              <p><em>M&oacute;j wniosek o dostęp, kopię i dodatkowe informacje obejmuje zatem koncepcję</em></p>
              <ul>
              <li><strong><em>dane osobowe w najszerszym znaczeniu, w tym między innymi </em></strong><em>notatki, komentarze, recenzje, oceny i wszystkie dane dotyczące mojej osoby lub dane osobowe, w tym między innymi dane obserwacyjne lub nieprzetworzone dane dostarczone przeze mnie w związku z korzystaniem z usługi lub urządzenia (takie jak na przykład, ale nie wyłącznie, dane przetwarzane przez połączone urządzenia, historia transakcji, dzienniki aktywności, takie jak dzienniki dostępu, historia korzystania z witryny internetowej, działania związane z wyszukiwaniem, dane dotyczące lokalizacji i dane z nich pochodzące lub wywnioskowane, aktywność związana z klikaniem, unikalne aspekty zachowania danej osoby, takie jak pismo odręczne, naciśnięcia klawiszy, szczeg&oacute;lny spos&oacute;b prowadzenia pojazdu, jazdy, chodzenia lub m&oacute;wienia), </em></li>
              <li><strong><em>dane wynikające z innych danych</em></strong><em>, a nie dostarczone bezpośrednio przeze mnie (na przykład, ale nie wyłącznie, oceny, klasyfikacje oparte na wsp&oacute;lnych atrybutach itp.) </em></li>
              <li><strong><em>dane wywnioskowane z innych danych</em></strong><em>, a nie bezpośrednio dostarczone przeze mnie (na przykład, ale nie wyłącznie, w celu przypisania oceny, w celu zapewnienia zgodności z przepisami dotyczącymi przeciwdziałania praniu pieniędzy, wynikami algorytm&oacute;w i danymi z nich wywnioskowanymi, wynikami oceny stanu zdrowia lub procesu personalizacji lub rekomendacji itp.), dane pseudonimizowane w przeciwieństwie do danych anonimizowanych, metadane itp.</em></li>
              </ul>
              <p><strong><em>Jeśli Twoja organizacja uważa mnie za administratora danych, kt&oacute;re przetwarzacie</em></strong></p>
              <p><em>Ponadto, jeśli Wasza firma uważa mnie za administratora jakichkolwiek danych osobowych, w odniesieniu do kt&oacute;rych Wasza firma działa jako podmiot przetwarzający, proszę o dostarczenie mi <strong>wszystkich danych, kt&oacute;re przetwarzacie w moim imieniu w formacie nadającym się do odczytu maszynowego, </strong>zgodnie z Waszym obowiązkiem poszanowania mojego prawa do określenia środk&oacute;w i cel&oacute;w przetwarzania.</em></p>
              <p><strong><em>Artykuł 22:</em></strong></p>
              <p><em>Ponadto proszę o podanie następujących kategorii informacji:</em></p>
              <ol>
              <li><strong><em>Informacje o zautomatyzowanym podejmowaniu decyzji</em></strong></li>
              </ol>
              <p><em>Proszę o potwierdzenie, czy podejmowane są dotyczące mnie zautomatyzowane decyzje (w rozumieniu art. 22 RODO). Jeśli odpowiedź jest twierdząca, proszę o podanie istotnych informacji na temat zastosowanej logiki, a także znaczenia i przewidywanych konsekwencji takiego przetwarzania. (Artykuł 15(1)(h)).</em></p>
              <ol start="2">
              <li><strong><em>Metadane dotyczące przetwarzania</em></strong></li>
              </ol>
              <p><em>Wniosek ten obejmuje r&oacute;wnież metadane, do kt&oacute;rych mam prawo na mocy RODO. </em></p>
              <p><strong><em>Informacje o administratorach, podmiotach przetwarzających, źr&oacute;dle i transferach. </em></strong></p>
              <ul>
              <li><em>Tożsamość wszystkich wsp&oacute;ładministrator&oacute;w danych osobowych. </em></li>
              <li><em>Wszelkie <strong>strony trzecie, kt&oacute;rym ujawniono dane, wraz z </strong>danymi kontaktowymi zgodnie z art. 15 ust. 1 lit. c). </em></li>
              <li><em>Jeśli jakiekolwiek dane nie zostały zebrane, zaobserwowane lub uzyskane bezpośrednio ode mnie, proszę o podanie dokładnych informacji o <strong>źr&oacute;dle tych danych</strong>, w tym nazwy i kontaktowego adresu e-mail administratora danych ("z jakiego źr&oacute;dła pochodzą dane osobowe", art. 14 ust. 2 lit. f)/15 ust. 1 lit. g)).</em></li>
              <li><em>Proszę o potwierdzenie, gdzie moje dane osobowe są fizycznie przechowywane (w tym kopie zapasowe), a przynajmniej, <strong>czy na jakimkolwiek etapie opuściły one UE (jeśli tak, proszę r&oacute;wnież o wyszczeg&oacute;lnienie podstaw prawnych i zabezpieczeń takich transfer&oacute;w danych).</strong></em></li>
              </ul>
                   ')
            )
            
            ),
  
  
  nav_panel("Uber",
            card(h3("Wgraj plik od UBER"),
                     fileInput('target_upload', 'Wprowadz plik do
                          analizy', accept = c('text/csv',
                                               'text/comma-separated-values', '.csv')),
                 min_height = "150px"
              ),
            fluidRow(
              column(
                width = 5,
                card(
                  card_header("Częstość kwot otrzymanych za przjeazdy (netto)"),
                  plotlyOutput(outputId = "hist_plot"),
                  min_height = "400px"
                )
              ),
              column(
                width = 7,
                card(
                  card_header("Suma kwot otrzmanych za przejazdy (netto) wg godzin"),
                  plotlyOutput(outputId = "plot_hour_pay_sum"),
                  min_height = "400px"
                )
              )
            ),
            fluidRow(
              column(
                width = 4,
                card(
                  value_box(title = "Całkowity dochód z przewozów",
                            textOutput("income_total"),
                            showcase = bs_icon("wallet2")),
                  min_height = "200px",
                  width = "100px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Całkowity napiwek",
                            textOutput("tips_total"),
                            showcase = bs_icon("cash")),
                  min_height = "200px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Odsetek napiwków w dochodzie",
                            textOutput("share_tips"),
                            showcase = bs_icon("cash-coin")),
                  min_height = "200px"
                )
              )
            ),
            fluidRow(
              column(
                width = 6,
                card( card_header("Średnia kwot otrzmanych za przejazdy (netto) wg godzin"),
                      plotlyOutput(outputId = "plot_hour_pay_mean"),
                      min_height = "400px"
                )
              ),
              column(
                width = 6,
                card( card_header("Suma kwot otrzmanych za przejazdy (netto) wg dni tygodnia"),
                      plotlyOutput(outputId = "plot_order_pay_total"),
                      min_height = "400px"
                )
              )
            ),
            fluidRow(
              column(
                width = 4,
                card(
                  value_box(title = "Średni dochód na dzień",
                            textOutput("daily"),
                            showcase = bs_icon("calendar2-day")), 
                  min_height = "200px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Średni dochód na miesiąc",
                            textOutput("monthly"),
                            showcase = bs_icon("calendar2-month")),
                  min_height = "200px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Średni dochód na rok",
                            textOutput("yearly"),
                            showcase = bs_icon("calendar-date")),
                  min_height = "200px"
                )
              )
            ),
            card(card_header("Średnia kwot otrzmanych za przejazdy (netto) wg dni tygodnia"),
                 plotlyOutput(outputId = "plot_order_pay_mean"),
                 min_height = "400px"),
            fluidRow(
              column(
                width = 4,
                card(
                  value_box(title = "Calkowita liczba przejazdów",
                            textOutput("shift.vec1"),
                            showcase = bs_icon("car-front-fill")), 
                  min_height = "200px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Średnia liczba przejazdow miesięcznie",
                            textOutput("shift.vec2"),
                            showcase = bs_icon("taxi-front-fill")),
                  min_height = "200px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Średnia liczba przejazdow tygodniowo",
                            textOutput("shift.vec4"),
                            showcase = bs_icon("speedometer")),
                  min_height = "200px"
                )
              )
            ),
            fluidRow(
              column(
                width = 6,
                card( card_header("Całkowita kwota otrzmana za przejazdy (netto) wg miesiąca"),
                      plotlyOutput(outputId = "plot_order_pay_total_month"),
                      min_height = "400px"
                )
              ),
              column(
                width = 6,
                card( card_header("Średnia kwota otrzmana za przejazdy (netto) wg miesiąca"),
                      plotlyOutput(outputId = "plot_order_pay_mean_month"),
                      min_height = "400px"
                )
              )
            ),
            card(
              card_header("Zarobki za przejazd wg dnia"),
              DTOutput(outputId = "sample_table", width = "100%", height = "100%"),
              min_height = "600"
            ),

            
            col_widths = c(6, 6, 4, 4, 4, 6, 6, 4, 4, 4, 6, -6,6, 6, 12)
  ),
  nav_panel("Pyszne.pl",
            card(
              h3("Wgraj pliki od Pyszne.pl"),
              fluidRow(
                
              ),
              fileInput('pyszne_upload_delivery', 'Tutaj wprowadź plik fact_delivery', accept = c('text/csv',
                                               'text/comma-separated-values', '.csv')),
              fileInput('pyszne_upload_working_shift', 'Tutaj wprowadź plik fact_courier_working_shift.csv', accept = c('text/csv',
                                                                                                  'text/comma-separated-values', '.csv')),
    
              min_height = "300px"
            ),
            fluidRow(
              column(
                width = 4,
                card(
                  value_box(title = "Średnia dlugosc przejazdu",
                            textOutput("pysz.delivery.vec1"),
                            showcase = bs_icon("scooter")),
                  min_height = "200px",
                  width = "100px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Średnie opoźnienie dostawy",
                            textOutput("pysz.delivery.vec2"),
                            showcase = bs_icon("hourglass-bottom")),
                  min_height = "200px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Średni czas przejazdu",
                            textOutput("pysz.delivery.vec3"),
                            showcase = bs_icon("stopwatch")),
                  min_height = "200px"
                )
              )
            ),
            fluidRow(
              column(
                width = 6,
                card( card_header("Suma godzin przepracowana ogółem"),
                      plotlyOutput(outputId = "plot_pp_hours_sum"),
                      min_height = "400px"
                )
              ),
              column(
                width = 6,
                card( card_header("Suma godzin przepracowana średnio w tygodniu"),
                      plotlyOutput(outputId = "plot_pp_hours_week"),
                      min_height = "400px"
                )
              )
            ),
            fluidRow(
              column(
                width = 4,
                card(
                  value_box(title = "Liczba punktow, z ktorych odebrano zamowienia",
                            textOutput("pysz.delivery.vec4"),
                            showcase = bs_icon("scooter")),
                  min_height = "200px",
                  width = "100px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Liczba dowozow posilkow",
                            textOutput("pysz.delivery.vec5"),
                            showcase = bs_icon("hourglass-bottom")),
                  min_height = "200px"
                )
              ),
              column(
                width = 4,
                card(
                  value_box(title = "Liczba dowozow zakupow spożywczych",
                            textOutput("pysz.delivery.vec6"),
                            showcase = bs_icon("stopwatch")),
                  min_height = "200px"
                )
              )
            )
            
            
  )
)


 
ui <- secure_app(ui)


#################################### S E R V E R ####################################
# Define server logic
server <- function(input, output, session) {
  output$clip <- renderUI({
    rclipButton(
      inputId = "clipbtn",
      label = "Skopiuj wiadomość",
      clipText = "pp", 
      icon = icon("clipboard"),
      tooltip = "Skopiuj wiadomość",
      placement = "top",
      options = list(delay = list(show = 800, hide = 100), trigger = "hover")
    )
  })
  
  # call the server part
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })
  
  #### ORGANIZE DATA ####
  uber_data <- reactive({
    
    
    
    inFile <- input$target_upload
    file_name <- input$target_upload$name
    if (is.null(inFile)){
      return(NULL)}
    else if (!startsWith(file_name, "driver_payments") ) {
      showNotification("Plik musi zaczynać się od 'driver_payments'.", 
                       type = "error")
      # Reset the input
      return(NULL)
    }
    else
      
      # GET RID OF NOT NEEDED CATEGORIES 
      dd <- df %>%
      filter(Category != "cash_collected" & Category != "driver_payment_tolls") %>% 
      group_by(Local.Timestamp) %>% 
      summarise(total_earned = round(sum(Local.Amount),2)) %>% 
      arrange(Local.Timestamp)
    
    # FORMAT THE TIME DATA 
    dd$day <- day(dd$Local.Timestamp)
    dd$month <- month(dd$Local.Timestamp)
    dd$year <- year(dd$Local.Timestamp)
    dd$date <- as.Date(with(dd, paste(year, month, day,sep="-")), "%Y-%m-%d")
    dd$hours <- as.numeric(format(as.POSIXct(dd$Local.Timestamp), format = "%H"))
    
    # HISTOGRAM OF AVERAGE PAYS
    fig_hist <- ggplot(dd, aes(x = total_earned)) +
      geom_histogram(color = "#B6163A", fill = adjustcolor("#B6163A", alpha.f = 0.8)) +
      theme_minimal() +
      labs(title = "") +
      xlab("Wypłata (netto) za przejazd") +
      ylab("Liczba wystąpień") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none", 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "#000000", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="#000000")
      )
    
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_hist <- ggplotly(fig_hist)
    
    # WAGES BY HOURS
    dd_hour <- dd %>%
      group_by(hours) %>%
      summarise(total_earned = sum(total_earned),
                mean_earned = mean(total_earned)) %>%
      arrange(hours)
    
    # FORMAT TO HOUR FORMAT
    format_hour <- function(hour) {
      sprintf("%d:00", hour)
    }
    
    dd_hour$time <- format_hour(dd_hour$hours)
    
    # GRAPH HOUR_PAY SUM
    hour_pay_sum <- ggplot(dd_hour, aes(x = reorder(time, hours) , y = total_earned))+
      geom_bar( stat = "identity", color = "#B6163A", fill = adjustcolor("#B6163A", alpha.f = 0.8)) +
      theme_minimal() +
      labs(title = "") +
      xlab("Początek kursu") +
      ylab("Suma dochodu (w zł)") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_hour_pay_sum <- ggplotly(hour_pay_sum)
    
    # GRAPH HOUR_PAY MEAN
    hour_pay_mean <- ggplot(dd_hour, aes(x = reorder(time, hours) , y = mean_earned))+
      geom_bar( stat = "identity", color = "#B6163A", fill = adjustcolor("#B6163A", alpha.f = 0.8)) +
      theme_minimal() +
      labs(title = "") +
      xlab("Początek kursu") +
      ylab("Średni dochód (w zł)") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )
    
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_hour_pay_mean <- ggplotly(hour_pay_mean)
    
    
    
    # CHANGE FORMAT OF THE DATA TO THE WEEKDAYS + THEIR TRANSLATION TO POLISH
    dd$weekday <- weekdays(as.Date(dd$Local.Timestamp))
    dd$weekday <- tolower(dd$weekday)
    dd$weekday[dd$weekday == "monday"] <- "poniedziałek"
    dd$weekday[dd$weekday == "tuesday"] <- "wtorek"
    dd$weekday[dd$weekday == "wednesday"] <- "środa"
    dd$weekday[dd$weekday == "thursday"] <- "czwartek"
    dd$weekday[dd$weekday == "friday"] <- "piątek"
    dd$weekday[dd$weekday == "saturday"] <- "sobota"
    dd$weekday[dd$weekday == "sunday"] <- "niedziela"
    
    # Changeformat of the data to the number of month
    dd$month_name <- as.character(dd$month)
    dd$month_name[dd$month == "1"] <- "styczeń"
    dd$month_name[dd$month == "2"] <- "luty"
    dd$month_name[dd$month == "3"] <- "marzec"
    dd$month_name[dd$month == "4"] <- "kwiecień"
    dd$month_name[dd$month == "5"] <- "maj"
    dd$month_name[dd$month == "6"] <- "czerwiec"
    dd$month_name[dd$month == "7"] <- "lipiec"
    dd$month_name[dd$month == "8"] <- "sierpień"
    dd$month_name[dd$month == "9"] <- "wrzesień"
    dd$month_name[dd$month == "10"] <- "październik"
    dd$month_name[dd$month == "11"] <- "listopad"
    dd$month_name[dd$month == "12"] <- "grudzień"
    
    
    # CREATE A NAMED VECTOR WITH ORDERING OF THE DAYS
    day_order <- c("poniedziałek" = 1, "wtorek" = 2, "środa" = 3, "czwartek" = 4, "piątek" = 5, "sobota" = 6, "niedziela" = 7)
    month_order <- c("styczeń" = 1,
                     "luty" = 2,
                     "marzec" = 3, 
                     "kwiecień" = 4,
                     "maj" = 5,
                     "czerwiec" = 6,
                     "lipiec" = 7,
                     "sierpień" = 8,
                     "wrzesień" = 9,
                     "październik" = 10,
                     "listopad" = 11,
                     "grudzień" = 12
    )
    
    # SET THE FACTOR LEVELS FOR WEEKDAY BASED ON DAY_ORDER
    dd$weekday <- factor(dd$weekday, levels = names(day_order))
    dd$month_name <- factor(dd$month_name, levels = names(month_order))
    
    # CREATE THE NEW VARIABLE 
    dd$day_order <- day_order[dd$weekday]
    dd$month_order <- month_order[dd$month_name]
    
    dd_order <- dd %>% 
      group_by(weekday, day_order) %>% 
      summarise(total_earned_sum = sum(total_earned),
                mean_earned = mean(total_earned)) %>% 
      arrange(day_order)
    
    dd_order_month <- dd %>% 
      group_by(month_name, month_order) %>% 
      summarise(total_earned_sum = sum(total_earned),
                mean_earned = mean(total_earned)) %>% 
      arrange(month_order)
    
    # GRAPH SUM BY THE DAY OF THE WEEK WITHOUT reorder()
    order_pay_total <- ggplot(dd_order, aes(x = weekday , y = total_earned_sum))+
      geom_bar( stat = "identity", color = "#B6163A", fill = adjustcolor("#B6163A", alpha.f = 0.8)) +
      theme_minimal() +
      labs(title = "") +
      xlab("Dzień kursu") +
      ylab("Całkowity dochód (w zł)") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none", 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )
    
    
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_order_pay_total <- ggplotly(order_pay_total)
    
    # GRAPH MEAN BY THE DAY OF THE WEEK
    order_pay_mean <- ggplot(dd_order, aes(x = weekday, y = mean_earned))+
      geom_bar( stat = "identity", color = "#B6163A", fill = adjustcolor("#B6163A", alpha.f = 0.8)) +
      theme_minimal() +
      labs(title = "") +
      xlab("Dzień kursu") +
      ylab("Średni dochód za przejazd (w zł)") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none", 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )
    
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_order_pay_mean <- ggplotly(order_pay_mean)
    
    # GRAPH BY THE MONTH 
    order_pay_month_total <- ggplot(dd_order_month, aes(x = month_name , y = total_earned_sum))+
      geom_bar( stat = "identity", color = "#B6163A", fill = adjustcolor("#B6163A", alpha.f = 0.8)) +
      theme_minimal() +
      labs(title = "") +
      xlab("Miesiąc kursu") +
      ylab("Całkowity dochód (w zł)") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none", 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )
    
    
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_order_pay_month_total <- ggplotly(order_pay_month_total)
    
    # GRAPH MEAN BY THE DAY OF THE WEEK
    order_pay_month_mean <- ggplot(dd_order_month, aes(x = month_name, y = mean_earned))+
      geom_bar( stat = "identity", color = "#B6163A", fill = adjustcolor("#B6163A", alpha.f = 0.8)) +
      theme_minimal() +
      labs(title = "") +
      xlab("Dzień kursu") +
      ylab("Średni dochód za przejazd (w zł)") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none", 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )
    
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_order_pay_month_mean <- ggplotly(order_pay_month_mean)
    
    # VISUALISATION ON SHIFTS 
    
    ##### PROVIDE INFOMRATION FOR THE USER ON THEIR INCOME EARNED THROUGH THE PLATFORM
    # SUM THE INCOME  
    dd$id <- 1
    
    # TOTAL EARNED
    total.income <- dd %>% 
      group_by(id) %>% 
      summarise(suma = sum(total_earned))
    total.income <- total.income$suma
    
    # TIPS
    total.tips <- df %>%
      filter(Classification == "transport.misc.tip") %>% 
      summarise(suma = round(sum(Local.Amount),2))
    total.tips <- total.tips$suma
    
    # SHARE OF TIPS IN INCOME 
    share.tips <- round((total.tips / total.income), 2) * 100
    
    # SAVE TO INCOME VECTOR 
    income.vec <- c(total.income, total.tips, share.tips)
    
    # Average income per day, month and year
    ## DAY
    total.income.day <- dd %>% 
      group_by(date) %>% 
      summarise(suma = sum(total_earned),
                count = sum(id))
    total.income.day <- round(weighted.mean(total.income.day$suma, total.income.day$count), 2) 
    
    ## MONTH
    total.income.month <- dd %>% 
      group_by(month) %>% 
      summarise(suma = sum(total_earned),
                count = sum(id)) 
    total.income.month <- round(weighted.mean(total.income.month$suma, total.income.month$count), 2)
    
    ## YEAR
    total.income.year <- dd %>% 
      group_by(year) %>% 
      summarise(suma = sum(total_earned),
                count = sum(id)) 
    total.income.year <- round(weighted.mean(total.income.year$suma, total.income.year$count), 2)
    
    # SAVE TO VECTOR
    income.vec.time <- c(total.income.day, total.income.month, total.income.year)
    
    # DATA ON NUMBER OF SHIFTS 
    total.shifts <- length(dd$total_earned) 
    
    average.shifts.year <- dd %>% 
      group_by(year) %>% 
      summarise(number = n())
    average.shifts.year <- round(mean(average.shifts.year$number), 2)
    
    average.shifts.month <- dd %>% 
      group_by(month) %>% 
      summarise(number = n())
    average.shifts.month <- round(mean(average.shifts.month$number), 2)
    
    dd$weeks <- strftime(dd$Local.Timestamp, format = "%V")

    average.shifts.week <- dd %>% 
      group_by(weeks) %>% 
      summarise(number = n())
    average.shifts.week <- round(mean(average.shifts.week$number), 2)
    
    shift.vec <- c(total.shifts, average.shifts.month, average.shifts.year, average.shifts.week)
    # Total number of completed shifts: 553
    # Average number of completed shifts by year: 138.25
    # Average number of completed shifts by month: 13.825
    # Average number of completed shifts by week: 3.45625
    
    # REORDER THE TABLE AND TRANSLATE TO POLISH
    dd <- dd[, c("day", "month", "year", "Local.Timestamp", "total_earned")]
    
    dd <- dd %>% 
      rename(
        Data = Local.Timestamp,
        Dzień = day,
        Miesiąc = month,
        Rok = year,
        Dochód = total_earned
      )
    
    list(data = dd,
         plot_hist = fig_hist,
         plot_hour_pay_sum = fig_hour_pay_sum,
         plot_hour_pay_mean = fig_hour_pay_mean,
         plot_order_pay_total = fig_order_pay_total,
         plot_order_pay_mean = fig_order_pay_mean,
         plot_order_pay_total_month = fig_order_pay_month_mean,
         plot_order_pay_mean_month = fig_order_pay_month_total, 
         var = income.vec, 
         var_month = income.vec.time,
         shift.vec = shift.vec
    )
    
    })
  pyszne_data <- reactive({
    ##### PYSZNE TAB ####

    
    inFile1 <- input$pyszne_upload_delivery
    file_name1 <- input$pyszne_upload_delivery$name
    if (is.null(inFile1))
      return(NULL)
    else if (file_name1!= "fact_delivery.csv"){
      showNotification("Plik musi nazywać się 'fact_delivery.csv'", 
                       type = "error")
      # Reset the input
      return(NULL)
  }
  else
    
    pp_d <- read.csv(inFile1$datapath, header = TRUE, sep = ",")
    
    inFile2 <- input$pyszne_upload_working_shift
    file_name2 <- input$pyszne_upload_working_shift$name
    if (is.null(inFile2))
      return(NULL)
    else if (file_name2!= "fact_courier_working_shift.csv"){
      showNotification("Plik musi nazywać się 'fact_courier_working_shift.csv'", 
                       type = "error")
      # Reset the input
      return(NULL)
    }
    else
    pp_c <- read.csv(inFile2$datapath, header = TRUE, sep = ",")
      
   
    pysz.mean.dist <-  round(mean(as.numeric( pp_d$delivery_travel_distance)/ 1000, na.rm =T), 2) 
    
    pp_d$lag_delivery <- difftime(ymd_hms(pp_d$delivery_arrival_datetime), ymd_hms(pp_d$delivery_expected_at_assigned_datetime), units = "secs")
    pp_d$time_delivery <- difftime(ymd_hms(pp_d$pickup_arrival_at_restaurant_datetime), ymd_hms(pp_d$delivery_arrival_datetime), units = "secs")
    
    pysz.mean.lag <- -1 * round(as.numeric(mean(pp_d$lag_delivery, na.rm =T)) / 60, 2)
    pysz.time.delivery <- -1 * round(as.numeric(mean(pp_d$time_delivery, na.rm = T)) / 60,2)
    
    pysz.unique.rest <- length(unique(pp_d$restaurant_id))
    pysz.food.num <- length(pp_d$delivery_type[pp_d$delivery_type == "FOOD"])
    pysz.groc.num <- length(pp_d$delivery_type[pp_d$delivery_type == "GROCERY"])
    
    pysz.delivery.vec <- c(pysz.mean.dist, pysz.mean.lag, pysz.time.delivery, pysz.unique.rest, pysz.food.num, pysz.groc.num)
    
    
    # Most basic bubble plot
    pp_c$date <- as.Date(ymd_hms(pp_c$start_datetime))  
    pp_c$weeks <- strftime(pp_c$date, format = "%V")
    
    pp_c_weeks <-pp_c %>% 
      group_by(date, weeks) %>% 
      summarise(sum_duration = sum(shift_duration)/3600,
                number_shifts = n())
    
    pp_c_weeks2 <-pp_c %>% 
      group_by(weeks) %>% 
      summarise(sum_duration = sum(shift_duration)/3600,
                number_shifts = n())
    
    
    pp_hours_sum <- ggplot(pp_c_weeks, aes(x = date , y = sum_duration)) +
      geom_line(color = "#B6163A") + 
      geom_point() +
      theme_minimal() +
      xlab("Data") +
      ylab("Godziny pracy") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none", 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )
    
    pp_hours_sum_week <- ggplot(pp_c_weeks2, aes(x = weeks , y = sum_duration, group = 1)) +
      geom_line() + 
      geom_point() +
      theme_minimal() +
      xlab("Data") +
      ylab("Suma godziny prac w  tygodniu") +
      theme(
        panel.grid.major = element_blank(),
        legend.position = "none", 
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.text=element_text(size = 12),
        axis.text.x=element_text(size = 12, angle = 45),
        axis.title=element_text(size = 12),
        axis.line = element_line(size = 0.5, colour = "grey", linetype = 1),
        axis.ticks = element_line(size = 0.5, color="grey")
      )+ geom_hline(yintercept=40, linetype="dashed", 
                    color = "#000000", size = 1)  +
      geom_text(aes(06, 35, label = "Pelen etat", vjust = -1))
    
    # SAVE THE GRAPH TO PLOTLY (INTERACTIVITY)
    fig_pp_hours_sum <- ggplotly(pp_hours_sum)
    fig_pp_hours_sum_week <- ggplotly(pp_hours_sum_week)
    
    
    
    # RETURN THE LIST IN OUTPUT
    list(pysz.delivery.vec = pysz.delivery.vec,
         plot_pp_hours_sum = fig_pp_hours_sum,
         plot_pp_hours_week = fig_pp_hours_sum_week
         )
  })
  
  output$sample_table <- DT::renderDataTable({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    DT::datatable(df$data)
  })
  
  output$hist_plot <- renderPlotly({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    df$plot_hist
  })
  
  output$plot_hour_pay_sum <- renderPlotly({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    df$plot_hour_pay_sum
  })

  output$plot_hour_pay_mean <- renderPlotly({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    df$plot_hour_pay_mean
  })
  output$plot_order_pay_total <- renderPlotly({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    df$plot_order_pay_total
  })

  output$plot_order_pay_mean <- renderPlotly({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    df$plot_order_pay_mean
  })
  
  
  output$plot_order_pay_total_month <- renderPlotly({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    df$plot_order_pay_total_month
  })
  
  output$plot_order_pay_mean_month <- renderPlotly({
    df <- uber_data()
    if (is.null(df)) return(NULL)
    df$plot_order_pay_mean_month
  })
  
  
  output$income_total <- renderText({
    dane <- uber_data()
    #if (is.null(dane)) return("No data")
    paste(dane$var[1], "zł")
  })
  
  output$tips_total <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$var[2], "zł")
  })
  
  output$share_tips <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$var[3], "%")
  })
  
  output$daily <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$var_month[1], "zł")
  })
  
  output$monthly <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$var_month[2], "zł")
  })
  
  output$yearly <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$var_month[3], "zł")
  })
  
  
  
  output$shift.vec1 <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$shift.vec[1])
  })
  
  
  output$shift.vec2 <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$shift.vec[2])
  })
  
  output$shift.vec3 <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$shift.vec[3])
  })
  
  output$shift.vec4 <- renderText({
    dane <- uber_data()
    if (is.null(dane)) return("No data")
    paste(dane$shift.vec[4])
  })
  
  # PYSZNE OUTPUT TAB 
  output$pysz.delivery.vec1 <- renderText({
    dane <- pyszne_data()
    if (is.null(dane)) return("No data")
    paste(dane$pysz.delivery.vec[1], "km")
  })
  
  output$pysz.delivery.vec2 <- renderText({
    dane <- pyszne_data()
    if (is.null(dane)) return("No data")
    paste(dane$pysz.delivery.vec[2], "min")
  })
  
  output$pysz.delivery.vec3 <- renderText({
    dane <- pyszne_data()
    if (is.null(dane)) return("No data")
    paste(dane$pysz.delivery.vec[3], "min")
  })
  
  output$pysz.delivery.vec4 <- renderText({
    dane <- pyszne_data()
    if (is.null(dane)) return("No data")
    paste(dane$pysz.delivery.vec[4])
  })
  
  output$pysz.delivery.vec5 <- renderText({
    dane <- pyszne_data()
    if (is.null(dane)) return("No data")
    paste(dane$pysz.delivery.vec[5])
  })
  
  output$pysz.delivery.vec6 <- renderText({
    dane <- pyszne_data()
    if (is.null(dane)) return("No data")
    paste(dane$pysz.delivery.vec[6])
  })
  
  output$plot_pp_hours_sum <- renderPlotly({
    df <- pyszne_data()
    if (is.null(df)) return(NULL)
    df$plot_pp_hours_sum
  })
  
  output$plot_pp_hours_week <- renderPlotly({
    df <- pyszne_data()
    if (is.null(df)) return(NULL)
    df$plot_pp_hours_week
  })
  
}

# Run the application 
shinylive::export(appdir = "C:/Users/wojci/IBS Dropbox/Wojciech Szymczak/ShinyApp/app_too_much",
                  destdir = "C:/Users/wojci/IBS Dropbox/Wojciech Szymczak/ShinyApp/app_too_much/docs")
