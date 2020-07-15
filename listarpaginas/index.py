from flask import Flask
from flask import jsonify
app = Flask(__name__)
@app.route("/")
def hello():  
    #!/usr/bin/python3
    import requests
    #Criar request de sessao
    sessao = requests.Session()
    url = "http://mediawiki.vinnland.ml/api.php"
    #parametros de criação do json
    parametros = {
        "action": "query",
        "format": "json",
        "list": "allpages"
    }
    #Adicionar url e parametros ao get da sessao
    request = sessao.get(url=url, params=parametros)
    #Criar json
    DADOS = request.json()
    #Busca da lista
    paginas = DADOS["query"]["allpages"]
    #print ("PÁGINAS = ", paginas, "\n") ## Ligar para debug do request
    #print das paginas
    resultado=[]
    for pagina in paginas:
        resultado.append(pagina["title"])
        #print(pagina["title"])
    return jsonify(resultado)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int("5000"), debug=True)
