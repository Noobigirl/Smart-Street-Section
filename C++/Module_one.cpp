#include <iostream>
#include <string>
#include <fstream>
#include <vector>
using namespace std;

vector<double> time_min;
vector<double> h;
vector<double> Q;

void read_file() {
	
	ifstream file("..\\Matlab\\module_1_inputs.csv");

	if(!file.is_open()) {
	
		cout << "Error opening file!" << endl;

	}
	else {
		cout << "File opened successfully!" << endl;
	}

	char comma;
	double time_v, h_v, Q_v;

	string line;
	getline(file, line);

	while (file>> time_v >> comma>>Q_v >>comma>>h_v) {
		
		time_min.push_back(time_v);
		Q.push_back(Q_v);
		h.push_back(h_v);

	}
	file.close();


	cout << "Time: "<< time_min.size() << endl;
	cout << "Q: "<< Q.size() << endl;
	cout << "H: "<< h.size() << endl;
}

// Timer is to prevent the actuator from opening and closing rapidly

bool timer_start()
{
	int timer = 0;
	static int count = 5;
	count--;
	if (count == timer) {
		count = 5;
		return true;
	}
	return false;
}

bool actuator(const vector<double>& h, const vector<double>& Q) {
//HTo is the trigger value for height of water puddle
//QTo is the trigger value for flow rate of water
	
	double HTo = 0.004;
	double QTo = 0.15;
	
	bool actuator_state = false;
	

	for (int i = 0; i < 200; i++) {

		bool actuator_on = h[i] >= HTo || Q[i] >= QTo;
		bool actuator_off = h[i] < HTo && Q[i] < QTo;
		bool anti_chatter;

		if (actuator_on)
		{
			cout << "Actuator gates are open!!! at: " << i << endl;
			actuator_state = true;
			
		}
		else if (actuator_state) {
			bool anti_chatter = timer_start();
		}
		if (anti_chatter && actuator_off)
		{
			cout << "Actuator gates are closed!!! at: " << i << endl;
			actuator_state = false;

		}

		cout << "Actuator state: " << actuator_state << endl;
	}
	
return actuator_state;

}

int main() {
	read_file();
	actuator(h, Q);
	return 0;
}

