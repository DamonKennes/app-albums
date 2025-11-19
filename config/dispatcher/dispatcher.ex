defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  define_layers [ :static, :services, :api, :frontend, :fall_back, :not_found ]

  # In order to forward the 'themes' resource to the
  # resource service, use the following forward rule:
  #
  # match "/themes/*path", @json do
  #   Proxy.forward conn, path, "http://resource/themes/"
  # end
  #
  # Run `docker-compose restart dispatcher` after updating
  # this file.

  match "/albums/*path", %{accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://resource/albums/"
  end

  match "/artists/*path", %{accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://resource/artists/"
  end

  match "/ratings/*path", %{accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://resource/ratings/"
  end

  match "/gebruikers/*path", %{accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://resource/gebruikers/"
  end

  match "/useraccounts/*path", %{accept: [:json], layer: :api} do
    Proxy.forward conn, path, "http://resource/useraccounts/"
  end

  # Login
  match "/sessions/*path", @any do
    Proxy.forward conn, path, "http://login/sessions/"
  end

  # Registration
  match "/accounts/*path", @any do
    Proxy.forward conn, path, "http://registration/accounts/"
  end

  match "/assets/*path", %{layer: :api} do
    Proxy.forward(conn, path, "http://frontend/assets/")
  end

  match "/@appuniversum/*path", %{layer: :api} do
    Proxy.forward(conn, path, "http://frontend/@appuniversum/")
  end

  match "/*path", %{accept: [:html], layer: :api} do
    Proxy.forward(conn, [], "http://frontend/index.html")
  end

  match "/*_path", %{layer: :frontend} do
    Proxy.forward(conn, [], "http://frontend/index.html")
  end

 # match "/useraccounts/*path", @any do
 #   Proxy.forward conn, path, "http://resource/useraccounts/"
 # end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
